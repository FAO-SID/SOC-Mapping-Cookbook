# SOC-Mapping-Cookbook
The Soil Organic Carbon mapping Cookbook


![](https://travis-ci.org/FAO-GSP/SOC-Mapping-Cookbook.svg?branch=master)

This is the website for the second edition of the cookbook. The cookbook provides generic methodologies and technical steps to 
produce SOC maps. This edition has been updated with knowledge and practical experiences gained during the implementaion 
process of GSOCmap V1.0 throughout 2017. The cookbook includes step-by-step guidance for developing 1 km grids for SOC 
stocks, as well as for the preparation of local soil data, the compilation and preprocessing of ancillary spatial data 
sets, upscaling methodologies, and uncertainty assessment methods. Guidance is mainly specific to SOC data, but as this 
cookbook contains generic sections on soil grid development it can be applicsable to map various soil properties. 

The guidance is focusing on the upscaling of national SOC stocks in order to produce the GSOCMap. Therefore, the 
cookbook supplements the [*GSP Guidelines for Sharing National Data/Information to Compile a Global Soil Organic 
Carbon (GSOC) Map](http://www.fao.org/3/a-bp164e.pdf), providing technical guidelines to prepare and evaluate spatial 
soil data sets to: 

* Determine SOC stocks from local samples to a target depth of 30 cm;
* Prepare spatial covariates for upscaling; and
* Select and apply the best suitable upscaling methodology.

This books introduce 5 different approaches for obtaining the SOC maps. The first two methods presented are classified 
as convetional upscaling. The first one is class-matching. In this approach we derive average SOC stocks per class: 
soil type for which a national map exists, or combination with other spatial covariates (e.g. land use category, 
climate type, biome, etc.). This approach is used in the absence of spatial coordinates of the source data. The s
econd one is geo-matching, were upscaling is based on averaged SOC values per mapping unit. Then, we present 3 methods 
from digital soil mapping. Regression-Kriging is a hybrid model with both, a deterministic and a stochastic component 
[@hengl2007regression]. Next method is called random forest. This one is an ensemble of regression trees based on bagging.
This machine learning algorithm uses a different combination of prediction factors to train multiple regression trees 
[@Breiman1996]. The last method is called support Vector Machines (SVM). This method applies a simple linear method to 
the data but in a high-dimensional feature space non-linearly related to the input space [@Karatzoglou2006]. We present 
this diversity of methods because there is no best mapping method for digital soil mapping, and testing and selection 
has to be done for every data scenario [@soil-2017-40].
