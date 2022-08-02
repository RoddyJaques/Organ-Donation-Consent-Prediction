# Organ Donation Consent Prediction
Author: *Roddy Jaques* <br/>
Contact: roderick.jaques@nhsbt.nhs.uk

[DSAproject.yml](DSAproject.yml) contains the Python environment used in this project.

## Contents
- [About this project](#about)
- [Description of Notebooks](#bookdesc)
- [Acknowledgements](#author)

<a name="about"/>

## About this project
This project was completed as part of the UK Civil Service Data Science Accelerator program. The aim of the project is to compare machine learning models' ability to predict family consent for organ donation with logistic regression models from a previous analysis.

The previous analysis by [Curtis et al](https://doi.org/10.1111/anae.15485) used data on all family approaches (16,896) for donation in UK intensive care units or emergency departments between April 2014 and March 2019 extracted from the referral records and the national potential donor audit held by NHS Blood and Transplant to fit logistic regression models to analyse factors influencing family consent for organ donation in the UK. Two models were fit, one for a cohort of donation after brain death (DBD) donors and one for a cohort of donation after circulatory death (DCD) donors.

In this project the same dataset was used to recreate the logistic regression models in Python and fit machine learning models to compare their ability to predict family consent for organ donation. Balanced accuracy was used as a metric to assess models due to an imbalance in the models ability to predict family consents and non-consents.

The original logistic regression model has a balanced accuracy of 67% for the DBD cohort, and 71% for the DCD cohort. 

The most effective models, scored by their balanced accuracy, were found to be random forest models. For the DBD cohort the balanced accuracy of the random forest model is 75% and the balanced accuracy of the random forest model fit to the DCD cohort is 72%. 

<a name="bookdesc"/>

## Description of Notebooks

[1 Verifying Logistic Regression.ipynb](1%20Verifying%20Logistic%20Regression.ipynb)<br/>
An introduction to the project and logistic regression models are fit to replicate the models in the previous analysis. 

[2 New logistic regression.ipynb](2%20New%20logistic%20regression.ipynb)<br/>
Logistic regression models are fit using a train and test split, and the testing set used to calculate model metrics to benchmark other models against.

[3 L2 Penalised Logistic regression.ipynb](3%20L2%20enalised%20Logistic%20regression.ipynb)<br/>
Logistic regression models are fit with L2 penalisation and compared to the benchmark.

[4 Decision Tree.ipynb](4%20Decision%20Tree.ipynb)<br/>
Decision tree models are fit and hyperparameters are tuned using a cross validated grid search. 

[5 Random forest.ipynb](5%20Random%20forest.ipynb)<br/>
Random forest models are fit and hyperparameters are tuned using a cross validated grid search. 

[6 Random forest without positive donation decision.ipynb](6%20Random%20forest%20without%20positive%20donation%20decision.ipynb)<br/>
The wish variable is removed from the data and random forest models are fit to the data without the wish variable. 

[7 Boosted forest.ipynb](7%20Boosted%20forest.ipynb)<br/>
Boosted forest models are fit and hyperparameters are tuned using a cross validated grid search. And conclusions of the project.

<a name="author"/>

## Acknowledgements
For their contributions to this project, I would like to thank:
- Maarten Van Schaik, my mentor through the DSA programme for sharing his knowledge of machine learning and statistics.
- Rebecca Curtis, for collecting and sharing the dataset used in this project and sharing her experience and expertise. 


