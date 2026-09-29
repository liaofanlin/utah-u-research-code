clc; clear all; close all;
% get the parameters
    sub_top_parameter;



    tic
    func_wrfout_process('openwrf', YEAR, MONTH, DAY, HOUR, WRF_X1, WRF_X2, WRF_Y1, WRF_Y2, DOMAIN);
    func_wrfout_process('darun'  , YEAR, MONTH, DAY, HOUR, WRF_X1, WRF_X2, WRF_Y1, WRF_Y2, DOMAIN);

    sub_analysis
    toc
    close all;
