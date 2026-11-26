#' Bandwidth estimation
#' @importFrom np npcdistbw
#' @importFrom parallel mclapply
#' @noRd
bandwidth <- function(time, event, new_x, cmin = 1, cmax = 5,
                      ncores = 1){
  ## compute bandwidth of x.1,...,x.q
  ## bandwidth is needed to compute the NWwight B.nk(x)
  #
  # data: time, event, X.1,...,X.q
  # output: bandiwidth hn, dim is q*1
  q <- dim(new_x)[2]
  n <- dim(new_x)[1]
  idx_0 <- which(event == 0)
  idx_1 <- which(event == 1)
  hn <- NULL  # the bandwidth of X.1,...,X.q
  h_pairs <- mclapply(seq_len(q), function(i) {
    x_col <- new_x[, i]
    h.0 <- np::npcdistbw(ydat = time[idx_0], xdat = x_col[idx_0], cxkertype="epanechnikov")$xbw  # for delta=0, compute bandwidth of Y and x.i
    h.1 <- np::npcdistbw(ydat = time[idx_1], xdat = x_col[idx_1], cxkertype="epanechnikov")$xbw  # for delta=1, compute bandwidth of Y and x.i
    c(h.0, h.1)
  }, mc.cores = ncores)

  # Combine results into a matrix and take row means
  h_mat <- do.call(rbind, h_pairs)
  h_mean <- rowMeans(h_mat)

  # Vectorized truncation between cmin * n^(-2/7) and cmax * n^(-2/7)
  n_factor <- n^(-2/7)
  hn <- pmax(pmin(h_mean, cmax * n_factor), cmin * n_factor)

  return(hn)
}

#' Estimate cumulative distribution function for the quantile mixture cure model
#' @noRd
F.C = function(data, w){
  ## compute F.C([t,inifint|x) = product_i {1 - b.ni(x)/sum_k B.nk(x)I(Y.k>=Y.i)}^{I(Y.i<=t and delta.i=0)}, at t=Y.i x=x.j, i=1,...,n, j = 1,...,n
  #
  # data:
  # w: NWeight = B.nk(x), dim is n*k, k =1,...,n
  # output:  F.C([Y.i,inifint|x.j), dim is n*n, the j row is the j person, the i col is F.C([Y.i,inifint|x.j)
  m = nrow(w)  # m rows
  n = ncol(w)  # n cols
  k = cbind(rep(0,m), w[,1:(n-1)])  # add 0 at first col and delete the last col of B.nk(x)
  cumsum.k = t(apply(k, 1, cumsum))  # sum_i B.ni(x)*I(Y.(i)<=t), the 1 col is t=Y.(0)=0, the 2 col is t=Y.(1), ...., the n col is t=Y.(n-1)
  cum.w = 1 - cumsum.k  # denominator: H([t,infinit)|x]) = sum_i B.ni(x)*I(Y.(i)>=t), the  1 col is t=Y.(1), the 2 col is t=Y.(2), ...., the n col is t=Y.(n)
  # numerator: w = B.ni(x)
  w = replace(w, cum.w==0, 0)  # if the denominator is 0, then the numerator is 0
  cum.w  = replace(cum.w, cum.w==0, 1)  # if the denominator is 0, then the denominator is 1
  q = 1 - w/cum.w   # 1 - B.ni(x)/ sum_k B.nk(x)*I(Y.(k)>=t), the j row is the j person, the 1 col is t=Y.(1), the i col is t=Y.(i), ...., the n col is t=Y.(n), dim is n*i
  delta = matrix(data$delta, nrow = m, ncol = n, byrow = TRUE)
  q = replace(q, delta==1, 1)  # if delta=1, then q = 1 - B.ni(x)/ sum_k B.nk(x)*I(Y.(k)>=t) is q=1
  q = t(apply(q, 1, cumprod))  # F.c([t,infinit)|x) = product_i {1 - B.ni(x)/ sum_k B.nk(x)*I(Y.(k)>=t)}^{I(Y.i<=t and delta.i=0)}, dim is n*i, the j row is the j person, the i col is F.c([t,infinit)|x) at t=Y.(i)
  return(q)
}

#' Estimate the conditional survival function and density function for the
#' latency component of the quantile cure mixture cure model
#' @noRd
F.T0 = function(data, w, PP.T, FF.C){
  ## compute F.T0((t,infinit)|x) = S.T0(t|x) = product_i {1 - H1(ds|x)/(H([Y.i,infinit)|x)-P(T=infinit|x)*F.C([Yi,infinit)|x}^I(Y.i<=t,delta=1)
  ## and compute f.T0(t|x) = F.T0(dt|x) = S.T0(Y.(i-1)|x.i) - S.T0(Y.i|x.i), at dt=Y.i and x=x.i
  #
  # w: NWeight = B.nk(x), dim is n*k, k =1,...,n
  # PP.T: P(T=infinit|x) = P(T=Y.n|x.j), j=1,...,n, dim is n*1
  # F.C: F.C([t,infinit)|x) = F.C([Y.i,inifinit)|x.j), i=1,...,n, j=1,...,n, dim is j*i
  #
  # output:
  # F.T0((t,infinit)|x) = S.T0(Y.i|x.i), i=1,...,n , dim is i*1
  # f.T0(t|x) = F.T0(dt|x) at dt=Y.i, x=x.i, d=1,...,n, dim is i*1
  #
  # Note: we can compute F.T0((t,infinit)|x) = S.T0(Y.i|x.j), the j row is the j person, the i col is F.T0((Y.i,inifint|x.j), dim is j*i
  # ..... but we only output S.T0(Y.i|x.i)

  # S.T0(Y.i|x.j)  dim is j*i, j=1,...,n, i=1,...,n
  m = nrow(w)
  n = ncol(w)
  k = cbind(rep(0,m), w[,1:(n-1)])  # add 0 at first col and delete the last col of B.nk(x)
  cumsum.k = t(apply(k, 1, cumsum))  # sum_i B.ni(x)*I(Y.(i)<=t), the 1 col is t=Y.(0)=0, the 2 col is t=Y.(1), ...., the n col is t=Y.(n-1)
  cum.w = (1 - cumsum.k) - PP.T*FF.C  # H([t,infinit)|x)-P(T=infinit|x)*F.C([t,infinit)|x), the j roe is the j person, the k col is this value H-P()*F.c at t=Y.(k)
  cum.w = cum.w*(cum.w>w+0.00001) + (w+0.0001)*(cum.w<=w+0.00001)  # ??? if the dinominator<numerator, then dinominator<numerato, then 1 - dinominator/nummerator = 0, then S.T0(t|x)=0
  q = 1 - w/cum.w  # q = 1 - H1(dt|x)/(H([t,infinit)|x)-P(T=infinit|x)*F.C([t,infinit)|x)), the j row is the j person, the i col is this value at t=Y.i
  delta = matrix(data$delta, nrow = m, ncol = n, byrow = TRUE)
  q = replace(q, delta==0, 1)  # if delta=0, then q=1
  q = t(apply(q, 1, cumprod))  # F.T0((t,infinit)|x) = S.T0(Y.i|x.j) = product_i {1 - H1(dt|x)/(H([t,infinit)|x)-P(T=infinit|x)*F.C([t,infinit)|x))}, the j row is the j person, the i col is  F.T0((t,infinit)|x) at t=Y.(i)
  # S.T0(Y.i|x.i)  dim is i*1, i=1,...,n
  S.T0 = diag(q) # F.T0((t,infinit)|x) = S.T0(Y.i|x.i)
  # f.T0(Y.i|x.i) dim is i*1, i=1,...,n
  qq = cbind(rep(1,n),q)  ## F.T0((t,infinit)|x), and add the value S(0|x)=1, each row denotes each person, each column denotes S(Y.(i)|x)
  qqq = c(t(qq))  # all n persons to be a vector
  r = apply(cbind(rep(n,n),rank(data[,1])),1,min)  # 1,2,...n
  s = seq(0,n-1,1)
  S.Yi1 = qqq[(n+1)*s+r]  # S.T0(Y.(i-1)|x.(i))
  S.Yi = qqq[(n+1)*s+r+1]  # S.T0(Y.(i)|x.(i))
  f.T0 = S.Yi1 - S.Yi  # f.T0(Y.i|x.i) = S.T0(Y.(i-1)|x.i) - S.T0(Y.i|x.i), i=1,...,n, dim is i*1
  return(list(S.T0 = S.T0, f.T0 = f.T0))
}


#' Estimate the coefficients in the latency component of the quantile mixture
#' cure model at the user-specified tau
#' @import quantreg
#' @importFrom stats model.matrix var
#' @noRd
Get_beta <- function(time, delta, x_matrix, S_T0, eta, tau, Large){
  ## calculate the beta by Qn(beta,eta,F.T0)
  #
  # S.T0: S.T0(Y.i|z.i), i=1,...,n, dim is n*1
  # eta: dim is n*1
  # lambda, the bootstrap diturbed value, dim is n*1
  n <- length(time)
  lambda <- rep(1, n)
  data <- cbind(time, delta, x_matrix)
  if ("(Intercept)" %in% colnames(data)) {
    data <- data[, -which(colnames(data) == "(Intercept)"), drop = FALSE]
  }

  F_T0 = 1 - S_T0  # F(Y.i|z.i) = 1 - S.T0(Y.i|z.i), where S.T0(Y.i|z.i)=F.T0((Y.i,infinit)|z.i)
  # weight w.i(F.T0)
  wght <- rep(1, n)
  denom <- pmax(1 - F_T0, 1e-8)
  for (j in 1:n) {
    if (delta[j] == 0 && F_T0[j] < tau) {
      wght[j] <- (tau - F_T0[j]) / denom[j]
    }
  }
  data <- cbind(data, wght) # add wght to the first n data
  eta1 <- eta # the eta value for the first n data
  lambda1 <- lambda
  # find censored data
  data_censor <- data[data[, "delta"] == 0, , drop = FALSE]
  if (nrow(data_censor) > 0) {
    data_censor[, "time"] <- Large
    data_censor[, "wght"] <- 1 - wght[data[, "delta"] == 0]
    eta2 <- eta[data[, "delta"] == 0]
    lambda2 <- lambda[data[, "delta"] == 0]
    data <- rbind(data, data_censor)
    eta <- c(eta1, eta2)
    lambda <- c(lambda1, lambda2)
  }
  if ("delta" %in% colnames(data)) {
    data <- data[, -which(colnames(data) == "delta"), drop = FALSE]
  }
  data <- as.data.frame(data)
  data$wght <- data$wght * eta * lambda
  fit <- quantreg::rq(time ~ . - wght, data = data, tau = tau, weights = wght)
  beta.est <- fit$coefficients
  return(beta.est)
}

#' Estimate eta, the conditional probability that the subject is
#' susceptible, from the quantile mixture cure model
#' @noRd
Get_eta <- function(time, delta, x, gamma, FF_T0){
  ## compute eta
  #
  # gamma: the estimator of gamma, dim is p2*1
  # FF.T0: F.T0((t,infinit)|x) = S.T0(Y.i|x.i), i=1,...,0, dim is i*1
  # output: the estimator of eta, dim is n*1
  # KJA : extract the covariate matrix
  n <- length(time)
  W <- as.matrix(x)  # the covariates
  Tau <- max(time[delta==1])  # the maximum of failure times
  gamma <- as.matrix(gamma)
  phi <- as.numeric( exp(W%*%gamma) / (1 + exp(W%*%gamma)) )  # dim is n*1
  eta = rep(1, n)
  for (i in 1:n) {
    if(delta[i] == 0 && time[i] <= Tau){
      eta[i] = phi[i]*FF_T0[i] / (1-phi[i] + phi[i]*FF_T0[i])
    }
    if(time[i] > Tau){
      eta[i] = 0
    }
  }
  return(eta)
}

#' Estimate the coefficients in the incidence component of the quantile mixture
#' cure model
#' @importFrom stats glm quasibinomial
#' @noRd
Get_gamma <- function(time, delta, x, FF_T0, ff_T0){
  ## compute the MLE of gamma
  #
  # FF.T0: F.T0((t,infinit)|x) = S.T0(Y.i|x.i), i=1,...,n, dim is i*1,
  # ff.T0: f.T0(t|x) = F.T0(dt|x) at dt=Y.i, x=x.i, d=1,...,n, dim is i*1
  n <- length(time)[1]
  lam <- rep(1, n)
  # KJA : extract the covariate matrix
  W <- as.matrix(x)  # the covariates
  liklhd <- function(param, W) {
    gamma <- as.matrix(param)
    phi <- as.numeric( exp(W%*%gamma) / (1 + exp(W%*%gamma)) )
    # KJA: Need to get the delta from the data object
    f <- delta * log(phi) + (1 - delta) * log(1 - phi + phi*FF_T0)
    f <- f * lam  # times the perturbed value of bootstrap method
    f <- sum(f)
    return(f)
  }
  initial <- glm(delta ~ W - 1,
                family = quasibinomial)$coefficients   # initial coefficients computed by logistic regression
  result <- maxLik::maxLik(logLik = liklhd, W = W, start = initial, method = 'BFGS')
  gamma_est <- result$estimate
  names(gamma_est) <- gsub("^W", "", names(gamma_est))
  return(gamma_est)
}

#' Normal kernel function used for computing weights for continuous covariates
#' @noRd
KK <- function(x, hn){
  # kernel function
  f <- 1/sqrt(2 * pi)*exp(-(x/hn)^2/2)  # Gaussian kernel
  return(f)
}

#' Kernel function used for computing weights for categorical variables
#' @noRd
KK2 <- function(x, hn){
  # the indicator function for a discrete covariate
  f <- hn^( ifelse(x != 0, 1, 0) )
  return(f)
}

#' Logit function
#' @noRd
logitf <- function(u){
  exp(u)/(1 + exp(u))
}

#' Calculate the Nadaraya-Watson weights
#' @noRd
nw_weight <- function(z, hn){
  # hn: bandwitdth of Z.0 and Z.1, dim is 2*1, Z.0 is intercept and its bandwith=1
  # lam: the disturb value from bootstrap (to compute standar err), if do not computer SE, set lam = rep(1,n)
  # dim of Z is n*p1
  # out put: n*k,k=1,...,n,  namely n*n
  z <- as.data.frame(z)
  n <- dim(z)[1]
  lam <- rep(1, n)
  p1 <- dim(z)[2]
  # each fixed p1(Z is two dims, p1=2), dim is n*n in which each column denotes a person
  MZ <- array(apply(z, 2, function(x) rep(x, n)), dim = c(n, n, p1))
  # each fixed p1(Z is two dims, p1=2), dim is n*n in which each row denotes a person
  tMZ <- aperm(MZ, c(2, 1, 3))
  # each fixed p1(Z is two dims, p1=2), dim is n*n, the i row is the i person, the k column detnotes a person's Z minus the k person's Z, namely Z-Z.k
  dMZ <- MZ - tMZ
  Kp <- array(NA, dim = c(n, n, p1))
  for(i in 1:p1){
    ## Kp[,,i] denotes for fixed Z.i, in the the n*n matrix, the k column denotes a person's Z minus the k person's Z
    # Kp[,,i]=KK(dMZ[,,i],hn[i])  # here, i deonts Z.i, i=1,2,...,p1'dim
    # KJA: Should probably change this logic for identifying a binary covariate
    if (sum(dMZ[,,i] == 1 | dMZ[,,i] == -1 | dMZ[,,i] == 0) == (n * n) &
       any(dMZ[,,i] != 0)){
      Kp[,,i] <- KK2(dMZ[,,i], hn[i]) # if Z is a binary covariate, use the Indicator function
    } else {
      Kp[,,i] <- KK(dMZ[,,i], hn[i]) # if Z is a continuous covariate, use a kernel function
    }
  }
  Lam <- matrix(lam, nrow = n, ncol = n, byrow = TRUE)
  prodKp <- apply(Kp, c(1, 2), prod)  # K(x) = K(x1) * K(X2), since Z is two dims. K(x) is n*n dim.
  lamKp <- prodKp*Lam  # each Z.k, times a disturbe value !!!
  # dim is n*n, the i row is the i person, the k column denbote Z-Z.k, namley a person's Z minus the k person's Z
  B_nk <- lamKp/matrix(apply(lamKp, 1, sum), nrow = n, ncol = n, byrow = FALSE)
  return(B_nk)
}

#' Estimate the probability that a subject is cured
#' @noRd
P.T = function(data, w){
  ## compute P(T=inifint|x.j) = product_i {1 - b.ni(x)/sum_k B.nk(x)I(Y.k>=t)}^{I(delta.i=1)}, at t=infinit=Y.n, x=x.j, j=1,...,n
  ## namely S.T(t|x) at t>=Y.(n)
  #
  # data:
  # w: NWeight = B.nk(x), dim is n*k, k =1,...,n
  # output: P(T=inifint|x.j), dim is j*1 , j=1,...,n
  m <- nrow(w)  # m rows
  n <- ncol(w)  # n cols
  k <- cbind(rep(0, m), w[, 1:(n - 1)])  # add 0 at first col and delete the last col of B.nk(x)
  cumsum_k <- t(apply(k, 1, cumsum))  # sum_i B.ni(x)*I(Y.(i)<=t), the 1 col is t=Y.(0)=0, the 2 col is t=Y.(1), ...., the n col is t=Y.(n-1)
  cum_w <- 1 - cumsum_k  # denominator: H([t,infinit)|x]) = sum_i B.ni(x)*I(Y.(i)>=t), the  1 col is t=Y.(1), the 2 col is t=Y.(2), ...., the n col is t=Y.(n)
  # numerator: w = B.ni(x)
  w <- replace(w, cum_w == 0, 0)  # if the denominator is 0, then the numerator is 0
  cum_w <- replace(cum_w, cum_w == 0, 1)  # if the denominator is 0, then the denominator is 1
  q <- 1 - w/cum_w  # 1 - B.ni(x)/ sum_k B.nk(x)*I(Y.(k)>=t), the j row is the j person, the 1 col is t=Y.(1), the i col is t=Y.(i), ...., the n col is t=Y.(n), dim is n*i
  delta <- matrix(data$delta, nrow = m, ncol = n, byrow = TRUE)
  q <- replace(q, delta == 0, 1)   # if delta=0, then q = 1 - B.ni(x)/ sum_k B.nk(x)*I(Y.(k)>=t) is q=1
  q <- t(apply(q, 1, prod))  # P(T=infinit|x.j) = S(Y.(n)|x.j) = product_i {1 - B.ni(x)/ sum_k B.nk(x)*I(Y.(k)>=t)} at x=x.j, dim is n*1, the j row is the j person at S(Y.(n)|x.j)
  return(as.numeric(q))
}

#' Sliced inverse regression
#' @noRd
sir_fun <- function(time, event, x,
                    n.slice1, n.slice0, n.slice, h, c) {
  # Always preserve the matrix structure
  x <- as.matrix(x)
  p <- ncol(x)
  # Special case: one covariate. No dimension reduction is needed
  if (p == 1L) {
    return(list(new_x = x, q_est = 1L))
  }
  # h = 0.2, c=0.05, n.slice1 = 5, n.slice0 = 5, p1
  x <- as.matrix(x)  # all covariates
  p1 <- dim(x)[2] + 1 # KJA: Add 1 to include the intercept
  # estimates of joint e.d.r. directions using the double slice
  ds <- double.slice(time, event, x, n.slice1 = n.slice1, n.slice0 = n.slice0)
  joint_edrs <- edr.n(ds, p1 - 1)  # the first p1 - 1 (-1 excludes Intercept) joint e.d.r. directions
  # estimates of e.d.r. lifetime directions using formulas (5.1), (5.2),
  #     (3.7)-(3.10) of Li, Wang and Chen 1999
  sir <- cen.sir(time, event, x, n.slice = n.slice, joint_edrs, h = h, c = c)
  # chi-square to select the estimate of q
  chi_square <- sir.test(sir)  # chi-square, see Theorem 5.1 of Li 1991
  # if all p-values of lambda_(p-K) > 0.05, then set q = 2
  if (sum(chi_square$p.value < 0.05) == 0) {
    q_est <- 2
  } else {
    q_est <- max(which(chi_square$p.value < 0.05))
  }
  # the e.d.r. lifetime reductions, namely the first q column
  #     eigenvectors: alpha.1,...,alpha.q
  evec <- sir$evec[, 1:q_est]
  # the primary information x = alpha * Z
  new_x = x%*%evec
  return(list(new_x = new_x, q_est = q_est))
}


################################
#### The following R code are for Slice Inverse Regression in censored data.
##### Program was developed by Dr. Wei Sun
##### and can be downloaded from http://www.bios.unc.edu/~weisun/software.htm

#' @importFrom stats cov
#' @noRd
"cen.sir" <-
  function(y, delta, x, n.slice, joint.edrs, h, c=0.05){
    "cov1" <-
      function(x, use="pair"){
        n = nrow(x);
        c = cov(x, use=use)*(n-1)/n;
        c
      }

    "kernel.est" <-
      function(Bx,h){
        n = nrow(Bx);
        r = ncol(Bx);
        b = rep(h, r);

        kernel.x = matrix(rep(0,n*n), nrow=n);
        for (i in 1:n){
          Bx.temp = t(matrix(rep(Bx[i,],n), nrow=r, ncol=n));
          d2 = ((Bx - Bx.temp)/b)^2;
          ds = apply(d2, 1, sum);
          fh = exp(-0.5*(ds));
          kernel.x[i,] = fh;
        }
        kernel.x
      }

    "cond.sur.est" <-
      function(kernel.mtr, y, c){
        n = length(y);
        s.hat = rep(0, n)
        for (i in 1:n){
          yi = (1:n)[y>y[i]];
          fh = kernel.mtr[i,];
          if(length(yi)>0){
            s.hat[i] = sum(fh[yi], na.rm=TRUE)/sum(fh, na.rm=TRUE);
            s.hat[i] = max(s.hat[i], c, na.rm=TRUE);
          }else{
            s.hat[i] = c;
          }
        }
        s.hat
      }

    "weight.est" <-
      function(t1, t2, index.x, y, delta, kernel.mtr, s.hat){
        if (t1 >= t2){
          cat(paste(t1, "\t", t2, "\n"));
          stop("t1 >= t2!");
        }

        # equation (5.2)
        fhatx0 = mean(kernel.mtr[index.x,], na.rm=TRUE)
        lambdahat.ttx.temp = kernel.mtr[index.x,] * (t1<y)*(y<t2) *  delta
        lambdahat.ttx = mean((lambdahat.ttx.temp / s.hat), na.rm=TRUE) / fhatx0

        # equation (5.1)
        weight.ttx = exp(-lambdahat.ttx)
        weight.ttx
      }

    "slice.time" <-
      function(t, h){
        lt=length(t);
        n1=ceiling(lt/h);
        n2=floor(lt/h);
        if(n1==n2){
          n = lt/h;
          index = rep(n, h);
        }else if(n1 > n2){
          h1 = lt%%h;
          h2 = h - h1;
          index = rep(c(n1, n2), c(h1, h2));
        }
        t.slice=numeric(h+1);  # (h+1) time points
        t.slice[1]=min(t) - 0.000001;
        end = 0;
        for(i in 1:h){
          bgn = end + 1;
          end = end + index[i];
          t.slice[i+1] = t[end];
        }
        t.slice
      }

    # order the data by survival time first
    ordr = order(y, -delta);
    y = y[ordr];
    # x = x[ordr,];
    # KJA: To allow a single covariate
    x = x[ordr, , drop = FALSE];
    delta = delta[ordr];

    # first, estimate the kernel matrix and conditional survial function
    Bx = x %*% joint.edrs;
    kernel.mtr = kernel.est(Bx, h);
    s.hat = cond.sur.est(kernel.mtr, y, c);

    # sencondly, calculate the slice mean m_h
    t.slice = slice.time(y, n.slice);
    m = matrix(0, nrow=n.slice, ncol=ncol(x));
    p.hat = rep(1,(n.slice+1));
    p = rep(1,n.slice);
    e.hat.x = matrix(0, nrow=(n.slice+1), ncol=ncol(x));
    x.bar = apply(x, 2, mean, na.rm=TRUE);
    e.hat.x[1,] = x.bar;
    nobs = length(y);

    for(j in 1:(n.slice-1)){
      weight.vect = rep(1,nobs);
      idx = (1:nobs);
      idx.case1 = idx[y<t.slice[(j+1)] & delta==0 & s.hat>c];
      idx.case2 = idx[y>=t.slice[(j+1)]];

      for(i in idx.case1){
        weight.vect[i] = weight.est(y[i], t.slice[(j+1)], i, y, delta,
                                    kernel.mtr, s.hat);
      }

      p.hat[(j+1)] = sum(weight.vect[idx.case1], na.rm=TRUE)/nobs;
      p.hat[(j+1)] = p.hat[(j+1)]+sum(weight.vect[idx.case2],na.rm=TRUE)/nobs;

      # KJA: Changed to allow for a single covariate
      if(length(idx.case1)>1){
        x.case1 = x[idx.case1, , drop=FALSE] * weight.vect[idx.case1]
        ave.case1 = apply(x.case1, 2, sum, na.rm=TRUE)/nobs;
      }else if(length(idx.case1)==1){
        ave.case1 = x[idx.case1, , drop=FALSE] * weight.vect[idx.case1]/nobs;
      }else if(length(idx.case1)==0){
        ave.case1 = 0;
      }

      if(length(idx.case2)>1){
        ave.case2 = apply(x[idx.case2, , drop=FALSE], 2, sum, na.rm=TRUE)/nobs;
      }else if(length(idx.case2)==1){
        ave.case2 = x[idx.case2, , drop=FALSE]/nobs;
      }else if(length(idx.case2)==0){
        ave.case2 = 0;
      }
      #if(length(idx.case1)>1){
      #  x.case1 = x[idx.case1,]*weight.vect[idx.case1]
      #  ave.case1 = apply(x.case1, 2, sum, na.rm=TRUE)/nobs;
      #}else if(length(idx.case1)==1){
      #  ave.case1 = x[idx.case1,]*weight.vect[idx.case1]/nobs;
      #}else if(length(idx.case1)==0){
      #  ave.case1 = 0;
      #}

      #if(length(idx.case2)>1){
      #  ave.case2 = apply(x[idx.case2,], 2, sum, na.rm=TRUE)/nobs;
      #}else if(length(idx.case2)==1){
      #  ave.case2 = x[idx.case2,]/nobs;
      #}else if(length(idx.case2)==0){
      #  ave.case2 = 0;
      #}

      e.hat.x[(j+1),] = ave.case1 + ave.case2;

      m[j,] = (e.hat.x[j,]-e.hat.x[(j+1),])/(p.hat[j]-p.hat[(j+1)]) - x.bar;
      p[j]  = p.hat[j] - p.hat[(j+1)];
    }

    m[n.slice,] = e.hat.x[n.slice,]/p.hat[n.slice] - x.bar;
    p[n.slice]  = p.hat[n.slice];

    # at last, compute the SIR direction
    mp = m*sqrt(p);
    sigma.eta = t(mp) %*% mp;
    sigma.x   = cov1(x, use="pair");
    eign = eigen.decomp(sigma.eta, sigma.x);

    ordr  = order(eign$values, decreasing=TRUE);
    e.val = eign$values[ordr];
    # e.vec = eign$vectors[,ordr];
    # KJA: Changed to allow a single covariate
    e.vec = eign$vectors[,ordr, drop = FALSE];

    if(is.null(colnames(x))){
      x.names = paste("X", 1:ncol(x), sep="");
    }else{
      x.names = colnames(x);
    }
    dimnames(e.vec) = list(x.names, paste("Dir", 1:ncol(e.vec), sep=""));

    csir = list(y=y, x=x, delta=delta, eval=e.val, evec=e.vec, nslice=n.slice);
    csir$c = c;
    csir$h = h;
    class(csir) = "csir";
    csir
  }


#' @importFrom stats cov
#' @noRd
"double.slice" <-
  function(y, delta, x, n.slice1, n.slice0){
    "cov1" <-
      function(x, use="pair"){
        n = nrow(x);
        c = cov(x, use=use)*(n-1)/n;
        c
      }
    "slice.idx" <-
      function(y, h, m){
        ly = length(y);
        if(m < max(y) ) {stop("y is not a valid index vector");}
        n1 = ceiling(ly/h);
        n2 = floor(ly/h);
        split = numeric(m);
        if(n1==n2){
          n = ly/h;
          index = rep(n, h);
        }else if(n1 > n2){
          h1 = ly%%h;
          h2 = h - h1;
          index = rep(c(n1, n2), c(h1, h2));
        }
        end = 0;
        for(i in 1:h){
          bgn = end + 1;
          end = end + index[i];
          split[y[bgn:end]] = i;
        }
        split
      }

    # order the data by survival time first
    ordr = order(y, -delta);
    y = y[ordr];
    # x = x[ordr,];
    # KJA: Changed to allow a single covariate
    x = x[ordr, , drop = FALSE];
    delta = delta[ordr];

    ds.idx = numeric(nrow(x));

    y.idx0 = (1:nrow(x))[delta==0];
    y.idx0 = y.idx0[order(y[delta==0])];
    ds.idx0 = slice.idx(y.idx0, n.slice0, nrow(x));

    y.idx1 = (1:nrow(x))[delta==1];
    y.idx1 = y.idx1[order(y[delta==1])];
    ds.idx1 = slice.idx(y.idx1, n.slice1, nrow(x));

    ds.idx[ds.idx0 > 0] = ds.idx0[ds.idx0 > 0];
    ds.idx[ds.idx1 > 0] = ds.idx1[ds.idx1 > 0] + n.slice0;

    n.per.slice = as.vector(table(ds.idx));
    probs = n.per.slice/nrow(x);

    for(i in 1:length(n.per.slice)){
      # x.slice = x[(1:nrow(x))[ds.idx==i],];
      # KJA: Changed to allow a single covariate
      x.slice = x[(1:nrow(x))[ds.idx==i], , drop = FALSE];
      cov.slice = cov1(x.slice, use="pair");
      if(i==1){
        ave.covx = probs[i]*cov.slice;
      }else{
        ave.covx = ave.covx + probs[i]*cov.slice;
      }
    }

    sigma.x = cov1(x, use="pair");
    sigma.eta = sigma.x - ave.covx;

    eign = eigen.decomp(sigma.eta, sigma.x);
    ordr = order(eign$values, decreasing=TRUE);
    e.val = eign$values[ordr];
    # e.vec = eign$vectors[,ordr];
    # KJA: Changed to allow a single covariate
    e.vec = eign$vectors[,ordr, drop = FALSE];

    if(is.null(colnames(x))){
      x.names = paste("X", 1:ncol(x), sep="");
    }else{
      x.names = colnames(x);
    }
    dimnames(e.vec) = list(x.names, paste("Dir", 1:ncol(e.vec), sep=""));

    n.s = n.slice1 + n.slice0;
    ds = list(y=y, x=x, delta=delta, eval=e.val, evec=e.vec, nslice=n.s);
    ds$nslice0 = n.slice0;
    ds$nslice1 = n.slice1;

    class(ds) = "ds";
    ds
  }

"edr.n" <-
  function(object, n){
    object$evec[,1:n]
  }

"edr.percent" <-
  function(object, percent){
    if(percent > 1 || percent < 0){
      stop("percent should be between 0 and 1\n");
    }

    values  = object$eval;
    vectors = object$evec;

    j=1;
    while(sum(values[1:j])/sum(values) < percent){
      j=j+1; # take the first j eigenvalues
    }
    pct = round(sum(values[1:j])/sum(values), 2);
    cat(paste("eigen.value =", "\n"));
    cat(signif(values,3));
    cat("\n");
    cat(paste("First", j, "eigen values explain",  pct, "variance", "\n"));
    cat("\n");

    vectors.mtr = vectors[,1:j];
    vectors.mtr
  }

"eigen.decomp" <-
  function(m1, m2, tol=1e-5){
    # cholesky decomposition of m2 = t(cm2) %*% cm2
    # and inverse(t(cm2)) = t(inverse(cm2))
    cm2 = chol(m2);
    inv.cm2 = cm2;
    idx.cm2 = diag(cm2)>tol;
    inv.cm2[idx.cm2, idx.cm2] = solve(cm2[idx.cm2, idx.cm2]);

    m3 = t(inv.cm2) %*% m1 %*% (inv.cm2);
    svd.m3 = svd(m3);
    eigen.value = svd.m3$d;
    eigen.vect = inv.cm2 %*% svd.m3$v;
    result = list(values=eigen.value, vectors=eigen.vect);
    result
  }

#' @importFrom stats pchisq
#' @noRd
"sir.test" <-
  function(object, nd=length(object$eval)) {
    if(!inherits(object, "csir") && !inherits(object, "ds")) {
    #if(class(object) != "csir" && class(object) != "ds") {
      stop("wrong class of object in sir.test\n");
    }
    e = sort(object$eval);
    p = length(object$eval);
    n = length(object$y);
    l = min(p, nd)
    chisq = numeric(l);
    df    = numeric(l);
    p.val = numeric(l);
    for (i in 0:(l-1)){
      j = i+1;
      chisq[j] = n*sum(e[1:(p-i)])
      df[j] = (p-i)*(object$nslice-i-1)
      p.val[j] = 1-pchisq(chisq[j], df[j])
    }
    test = data.frame(Chisq=chisq, df=df, p.value=p.val);
    rnames = character(l);
    for(i in 1:l){
      rnames[i] = paste("D=", i-1, " vs. ", "D>=", i, sep="");
    }
    rownames(test) = rnames;
    test
  }


#' Bootstrap resampling used by plot2 function.
#'
#' @description
#' Performs bootstrap resampling to estimate the standard errors
#' for various values of tau after fitting a mixture cure
#' model using \code{curequantile}. The results are used in the plot2 function.
#'
#' @param object an object of class \code{curequantile}.
#' @param B number of bootstrap resamples.
#' @param probs percentiles for a bootstrap confidence interval.
#' @param tau specific quantile at which estimates and
#' confidence intervals are to be constructed for each parameter.
#' @param large large positive constant at which to set times for those cured.
#' @param seed optional random seed to promote reproducibility.
#'
#' @importFrom stats model.frame model.response model.matrix quantile sd
#' @returns A list with the following components:
#' \item{beta_est}{estimated coefficients for beta (the latency component) at
#' the user-specified quantile tau.}
#' \item{beta_std_err}{bootstrap estimate of standard error for beta at the
#' user-specified quantile tau.}
#' @noRd
bootstrap_plot <- function(object, B, probs, tau, large,
                           seed){
  ## Get beta.est and beta.SE for several values of tau
  if (!is.null(seed)) {
    set.seed(seed)
  }
  mt <- object$terms
  data_edr <- object$data_edr
  hn <- object$hn
  wght <- nw_weight(data_edr[,-(1:2), drop = FALSE], hn)
  P.T_inf <- P.T(data_edr, wght)  # P(T=infinit|x.j), j=1,...,n
  F.C_YiZj <- F.C(data_edr, wght)  # F.C([t,inifint|x) at t=Y.i x=x.j
  S.T0 <- F.T0(data_edr, wght, P.T_inf, F.C_YiZj)$S.T0  # F.T0([t,infinit)|x)=S.T0(t|x) at t=Y.i, x=x.i, i=1,...,n
  f.T0 <- F.T0(data_edr, wght, P.T_inf, F.C_YiZj)$f.T0  # f.T0(t|x) = F.T0(dt|x) = S.T0(Y.(i-1)|x.i) - S.T0(Y.i|x.i), at dt=Y.i and x=x.i
  coef <- coef(object, tau = tau[1], large = large)
  beta_est <- matrix(0, ncol = length(coef$beta_est), nrow = length(tau))
  for (i in 1:length(tau)) {
    coef <- coef(object, tau = tau[i], large = large)
    gamma_est <- coef$gamma_est #Get_gamma(time, delta, x_matrix, S_T0, f_T0)
    eta_est <- coef$eta_est #Get_eta(time, delta, x_matrix, gamma_est, S_T0)
    beta_est[i,] <- coef$beta_est #Get_beta(time, delta, x_matrix, S_T0, eta_est, tau, large)
  }
  data.original <- object$data # Figure 2.R has log(Time) as Y
  hn.original <- object$hn
  p1 <- length(gamma_est)
  p2 <- dim(beta_est)[2]
  n <- nobs(object)
  SE.bootstrap.plot <- function(data.original, n, mt){
    index <- sample(1:n, n, replace = TRUE)
    data <- data.original[index,]
    mf_boot <- model.frame(mt, data = data)
    Y_boot  <- model.response(mf_boot)
    if (is.matrix(Y_boot) || inherits(Y_boot, "Surv")) {
      ord <- order(Y_boot[, 1])  # Sort by time variable
    } else {
      ord <- order(Y_boot)
    }
    data <- data[ord, , drop = FALSE]  # order by Y
    mf_boot  <- mf_boot[ord, , drop = FALSE]
    Y_sorted <- model.response(mf_boot)
    time <- Y_sorted[,1]
    event <- Y_sorted[,2]
    x <- model.matrix(mt, mf_boot)
    if ("(Intercept)" %in% colnames(x)) {
      x_no_intercept <- x[, colnames(x) != "(Intercept)", drop = FALSE]
    }
    sir_result <- sir_fun(time, event, x_no_intercept,
                          n.slice1 = object$n.slice1,
                          n.slice0 = object$n.slice0,
                          n.slice = object$n.slice,
                          h = object$sir_h, c = object$sir_c)
    X <- sir_result$new_x  # X = (alpha.1*Z....,alpha.1*Z), effective dimension reduction by SIR method
    q.est <- sir_result$q_est  # the estimated q, using chi-square test
    data_edr =  data.frame(Y = time, delta = event, x = X)  # bootstrap data after effective dimension redution
    if (q.est == length(hn.original)) {hn <- hn.original}
    if (q.est > length(hn.original)) {hn <- rep(hn.original[1], q.est)}
    if (q.est < length(hn.original)) {hn <- hn.original[1:q.est] }
    wght <- nw_weight(data_edr[,-(1:2), drop = FALSE], hn)
    P.T_inf <- P.T(data_edr, wght)  # P(T=infinit|z.j), j=1,...,n
    F.C_YiZj <- F.C(data_edr, wght)  # F.C([t,inifint|z) at t=Y.i z=z.j
    S.T0 <- F.T0(data_edr, wght, P.T_inf, F.C_YiZj)$S.T0  # F.T0([t,infinit)|z)=S.T0(t|Z) at t=Y.i, z=z.i, i=1,...,n
    f.T0 <- F.T0(data_edr, wght, P.T_inf, F.C_YiZj)$f.T0  # f.T0(t|z) = F.T0(dt|z) = S.T0(Y.(i-1)|z.i) - S.T0(Y.i|z.i), at dt=Y.i and z=z.i
    gamma.est.b <- Get_gamma(time, event, x, S.T0, f.T0)
    eta.est.b <- Get_eta(time, event, x, gamma.est.b, S.T0)
    beta.est.b <- matrix(0, ncol = p2, nrow = length(tau))
    for (j in 1:length(tau)) {
      beta.est.b[j,] <- Get_beta(time, event, x, S_T0 = S.T0, eta = eta.est.b,
                                 tau = tau[j], Large = large)
    }
    boot_results <- list(gamma.est.b, beta.est.b)
    #return(beta.est.b)
    return(boot_results)
  }
  bootstrap.results <- list()
  bootstrap.gamma <- matrix(0, ncol = p1, nrow = B)
  b <- 0
  bb <- 0
  while (bb < B){
    #cat(" b = ", b, "estimates = ", bb, "\n")
    bootbeta.est <- NULL
    est.max <- NULL
    fit <- NULL
    b <- b + 1
    fit <- try( {bootbeta.est = SE.bootstrap.plot(data.original, n, mt); est.max =  max(unlist(bootbeta.est))},
                silent=TRUE
    )  # error: Duplicating observations (for a single x value, multiple responses) increases chances of singularity.

    if (inherits(fit, "try-error") || is.null(bootbeta.est) ||
        anyNA(unlist(bootbeta.est)) || abs(est.max) > 100) {
      next
    }

    bb <- bb + 1
    bootstrap.results[[bb]] <- bootbeta.est[[2]]
    bootstrap.gamma[bb,] <- bootbeta.est[[1]]
  }
  boot_array <- simplify2array(bootstrap.results)
  se_matrix <- apply(boot_array, c(1, 2), sd)
  se_gamma <- apply(bootstrap.gamma, 2, sd)
  beta_percentile <- apply(boot_array, c(1, 2), function(x)
    quantile(x, probs = probs))
  gamma_percentile <- apply(bootstrap.gamma, 2, function(x)
    quantile(x, probs = probs))
  return(list(gamma_est = gamma_est,
              gamma_std_err = se_gamma,
              gamma_percentile = gamma_percentile,
              beta_est = beta_est,
              beta_std_err = se_matrix,
              beta_percentile = beta_percentile))
}
