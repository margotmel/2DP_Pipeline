close all
clear all
clc

featureTypes = [ ...
    "c_c_c" "c_c_c_c" "cr_c" "cr_c_c" "cr_cr" "cr_c_s" "cr_e" "cr_e_c" ...
    "cr_e_e" "cr_e_s" "cr_od" "cr_od_c" "cr_od_e" "cr_od_od" "cr_od_s" ...
    "cr_s" "cr_s_s" "lmax_quads" "lmax_triads" "od_c" "od_c_c" "od_c_s" ...
    "od_e" "od_e_c" "od_e_e" "od_e_s" "od_od" "od_od_c" "od_od_e" "od_od_s" ...
    "od_s" "od_s_s" "s_c_c" "s_c_c_c" "s_s_c" "s_s_c_c" "s_s_s" "s_s_s_c" "s_s_s_s" ...
];

for f = 1:length(featureTypes)
    filePath = strcat("/home/margot/2DP_Pipeline/storedPooledCountsImgNet/storingPooledCountsSub0_imgNetsum5ori_", featureTypes(f), ".mat");
    
    data = load(filePath);
    numCols = size(data.storingPooledCounts0Final, 2);
    
    fprintf("%-20s -> %d columns\n", featureTypes(f), numCols);
end
