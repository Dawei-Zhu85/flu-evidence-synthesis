#ifndef FLU_ODE_H
#define FLU_ODE_H

//#include "rcppwrap.h"
#include<Eigen/Core>

namespace ode {
    template<typename ODE_FUNC>
        Eigen::VectorXd step( Eigen::VectorXd &&y, ODE_FUNC &ode_func,
                double &step_size, double &current_time, 
                const double max_time )
        {
            auto dt = std::min( step_size, max_time - current_time );
            y = y + dt*ode_func( y, current_time );
            current_time += dt;
            return y;
        }

    template<typename ODE_FUNC>
        Eigen::VectorXd rkf45_astep( Eigen::VectorXd &&y, 
                ODE_FUNC &ode_func,
                double &step_size, double &current_time, 
                const double max_time, const double tol = 1e-2 )
        {
            static Eigen::VectorXd k1, k2, k3, k4, k5, k6, err;

            if (k1.size() != y.size())
            {
                k1 = Eigen::VectorXd( y.size() );
                k2 = k1;
                k3 = k1;
                k4 = k1;
                k5 = k1;
                k6 = k1;
                err = k1;
            }

            auto max_step = max_time - current_time;

            auto dt = std::min( step_size, max_step );

            bool adapted = true;
            while( adapted )
            {

                k1 = dt*ode_func(y, current_time);
                k2 = dt*ode_func(
                        y + 1.0/4.0*k1, 
                        current_time + 1.0/4.0*dt);
                k3 = dt*ode_func(
                        y + 3.0/32*k1+9.0/32*k2, 
                        current_time + 3.0/8.0*dt);
                k4 = dt*ode_func(
                        y + 1932.0/2197*k1-7200.0/2197*k2+7296.0/2197*k3, 
                        current_time + 12.0/13.0*dt);
                k5 = dt*ode_func(
                        y + 439.0/216*k1-8*k2+3680.0/513*k3-845.0/4104*k4, 
                        current_time + dt);
                k6 = dt*ode_func(
                        y - 8.0/27*k1+2.0*k2-3544.0/2565*k3+1859.0/4104*k4
                        -11.0/40*k5, 
                        current_time + 1.0/2.0*dt);

                err = ( 1.0/360*k1-128.0/4275*k3-2197.0/75240*k4
                        +1.0/50*k5+2.0/55*k6 );

                auto s = std::min(
                        std::max(
                            0.84*pow(tol*dt/err.norm(),0.25), 
                            0.25)
                        , 5.0 );

                if ((s > 2 || s < 0.5) && dt < max_step)
                {
                    step_size = s*dt; 
                    dt = std::min( step_size, max_step );
                } else {
                    adapted = false;
                }
            }

            current_time += dt;

            //Rcpp::cout << dt << ", " << step_size << ", " << current_time << std::endl;

            return y + 25.0/216*k1+1408.0/2565*k3+2197.0/4101*k4-
                1.0/5*k5;
        }
};

#endif
