# Sour grapes and sweet victories: how actions shape preferences
**Fabien Vinckier\*, Lionel Rigoux\*, Irma T. Kurniawan\*, Chen Hu,  Sacha Bourgeois-Gironde, Jean Daunizeau, Mathias Pessiglione**

This repo contains all the empirical data and Matlab code that were used in the paper published in PLoS Computational Biology.

## Requirement

Matlab with a the [VBA-toolbox](http://mbb-team.github.io/VBA-toolbox/) installed (see submodule).

## Structure of the code

- SG_load_data.m loads all the empirical measurements.
- SG_invert.m and SG_invert_subjects.m are the principal inversion routines
- the models are implemented in SG_g_model.m
- SG_main runs all the analyses that are reported in the paper and generates the main figures

Please note that the inversion process, especially for the Monte-Carlo simulations (bootstrapping) will generate a few Gb of data and require a rather large computational power.
