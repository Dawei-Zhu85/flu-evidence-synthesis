context("Contacts")

test_that("We can create a contact matrix using deprecated contact.matrix", {
      data(age_sizes)
      data(polymod_uk)
      age.group.limits <- c( 1,5,15,25,45,65 )
      expect_warning(cm <- contact.matrix( as.matrix(polymod_uk), age_sizes[,1], 
                           age.group.limits ))
      expect_lt( sum(cm), 7.06338e-06 + 1e-8 )
      expect_gt( sum(cm), 7.06338e-06 - 1e-8 )
      for (i in 1:nrow(cm))
        for (j in 1:nrow(cm))
          expect_equal( cm[i,j], cm[j,i])

      expect_warning(cm2 <- contact.matrix( as.matrix(polymod_uk), age_sizes[,1] ))
      expect_identical( cm, cm2 )
  }
)

test_that("We can create a contact matrix", {
      data(age_sizes)
      data(polymod_uk)
      age.group.limits <- c( 1,5,15,25,45,65 )
      cm <- contact_matrix( as.matrix(polymod_uk), age_sizes[,1], 
                           age.group.limits )
      expect_lt( sum(cm), 7.06338e-06 + 1e-8 )
      expect_gt( sum(cm), 7.06338e-06 - 1e-8 )
      for (i in 1:nrow(cm))
        for (j in 1:nrow(cm))
          expect_equal( cm[i,j], cm[j,i])

      cm2 <- contact_matrix( as.matrix(polymod_uk), age_sizes[,1] )
      expect_identical( cm, cm2 )
  }
)

test_that("We can use custom age limits", 
  {
      data(age_sizes)
      poly <- matrix( c( 5, 0, 4, 2, 
                        5, 1, 3, 1,
                        25, 0, 1, 5, 
                        25, 1, 2, 6 ), nrow = 4, byrow= TRUE)

      age.group.limits <- c( 15 )
      cm <- contact_matrix( poly, age_sizes[,1], 
                           age.group.limits )
      expect_equal( nrow(cm), 2 )
      expect_equal( ncol(cm), 2 )

      expect_equal( sum(cm>0), 4 ) # All greater than 0
      expect_lt( sum(cm), 6.682946e-07 + 1e-8 )
      expect_gt( sum(cm), 6.682946e-07 - 1e-8 )
  }
)

test_that("We throw an arror if custom age limits are not complete", 
  {
      data(age_sizes)
      data(polymod_uk)

      age.group.limits <- c( 15 )
      expect_error(contact_matrix(as.matrix(polymod_uk), age_sizes[,1], 
                           age.group.limits ))
  }
)

test_that("We can convert transmission_rate into R0 and opposite", {
    cm <- matrix(c(2, 0.1, 0.1, 1)/100, nrow = 2)
    pv <- c(50, 50)
    base <- as_R0(1, cm, pv)
    expect_equal(2*base, as_R0(1, cm, c(100,100), 1.8))
    expect_equal(2*base, as_R0(2, cm, c(50,50), 1.8))
    expect_equal(2*base, as_R0(1, cm, c(50,50), 2*1.8))
    expect_gt(as_R0(1, cm, c(150,50), 1.8), 2*base)
    expect_lt(as_R0(1, cm, c(50,150), 1.8), 2*base)
    
    # Calculate backwards
    expect_equal(as_transmission_rate(as_R0(1, cm, c(50,50), 1.8), cm, c(50,50), 1.8), 1)
  }
)

test_that("We can create a contact matrix using ages higher than 90", {
      data(demography)
      data(polymod_uk)
      age.group.limits <- c( 1,5,15,25,45,65 )
      orig_cm <- contact_matrix( as.matrix(polymod_uk), demography, 
                           age.group.limits )
      
      dim <- length(demography)
      demography <- c(demography[1:(dim-1)], 
                      rep((demography[dim]-demography[80])/9, 10))
      demography[93] <- demography[80]
      
      polymod_uk[nrow(polymod_uk),1] <- 92
      cm <- contact_matrix( as.matrix(polymod_uk), demography, 
                            age.group.limits )
      expect_lt(abs(orig_cm[7,7]-cm[7,7]), 1e-10)
  }
)
