import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier, plot_tree
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.neighbors import KNeighborsClassifier
import sklearn.metrics as mets


class Dataset:
    """
    Loads the SAS dataset and contains functions to create the DBD and DCD cohorts for modelling.
    """
    df = pd.read_sas("Data/alldata3.sas7bdat")
    
    def get_dbd(self):  
        """ Outputs the DBD features and DBD consents datasets """
        #6931 DBD apps
        dbd_apps = df[(df["eli_DBD"]==1)&(df["FAMILY_APPROACHED"]==2)]

        #6060 DBD apps to match cohort in paper
        dbd_apps = dbd_apps[(dbd_apps["eth_grp"]!=5)&(dbd_apps["FORMAL_APR_WHEN"]!=4)&(dbd_apps["donation_mentioned"]!=-1)
                            &(dbd_apps["FAMILY_WITNESS_BSDT"]!=9)&(dbd_apps["GENDER"]!=9)]

        # Columns used to create DBD model in paper
        dbd_cols = ["wish", "FORMAL_APR_WHEN", "donation_mentioned", "app_nature", "eth_grp", "religion_grp", "GENDER", "FAMILY_WITNESS_BSDT", "DTC_PRESENT_BSD_CONV", 
                    "acorn_new", "adult","FAMILY_CONSENT"]

        dbd_apps[dbd_cols].astype(int)

        dbd_model_data = dbd_apps[dbd_cols]
        dbd_model_data2 = pd.get_dummies(data=dbd_model_data,columns=dbd_cols[:-1],drop_first=True)

        dbd_features = dbd_model_data2.drop("FAMILY_CONSENT",axis=1)
        dbd_consents = dbd_model_data2["FAMILY_CONSENT"]

        return dbd_features, dbd_consents

    def get_dcd(self):
        """ Outputs the DCD features and DCD consents datasets """
        #9965 DCD apps
        dcd_apps = df[(df["eli_DCD"]==1)&(df["FAMILY_APPROACHED"]==2)]

        #9405 DCD apps to match cohort in paper
        dcd_apps = dcd_apps[(dcd_apps["GENDER"]!=9)&(dcd_apps["cod_neuro"].notna())&(dcd_apps["eth_grp"]!=5)&(dcd_apps["donation_mentioned"]!=-1)&
                            (~dcd_apps["DTC_WD_TRTMENT_PRESENT"].isin([8,9]))]
        
        # Columns used to create DCD model in paper
        dcd_cols = ["wish", "donation_mentioned", 
                    "app_nature", "eth_grp", "religion_grp", "GENDER", "DTC_WD_TRTMENT_PRESENT", 
                    "acorn_new", "adult","cod_neuro","FAMILY_CONSENT"]

        dcd_apps[dbd_cols].astype(int)

        dcd_model_data = dcd_apps[dcd_cols]
        dcd_model_data2 = pd.get_dummies(data=dcd_model_data,columns=dcd_cols[:-1],drop_first=True)

        dcd_features = dcd_model_data2.drop("FAMILY_CONSENT",axis=1)
        dcd_consents = dcd_model_data2["FAMILY_CONSENT"]

        return dcd_features, dcd_consents

def show_metrics(actual,predict):
    """ Prints the confusion matrix, balanced accuracy and accuracy given datasets of actual and predicted labels
    
    Arguments:
        actual - Dataset of actual labels
        predict - Dataset of predicted labels
     """
    cm = mets.confusion_matrix(actual, predict)

    print("TN  FN\nFP  TP\n")
    print(str(int(cm[0,0])) + "    " + str(int(cm[0,1])))
    print(str(int(cm[1,0])) + "    " + str(int(cm[1,1])) + "\n") 

    # classification report for DBD model
    print(mets.classification_report(actual, predict))

    print("Balanced accuracy: " + str(round(mets.balanced_accuracy_score(actual, predict),2)))

    print("Accuracy: " + str(round(mets.accuracy_score(actual, predict),2)))

def tree_hparam_plot(hparam,hp_array,X_train,y_train,X_test,y_test):
    """ Plots balanced accuracy and recall for both classes against a list of hyperparameter values for a decision tree classifier.
    
    Arguments:
        hparam - String with the name of the hyperparameter being tested
        hp_array - list of values of hparam being tested
        X_train - Training dataset predictors 
        y_train - Training dataset classes 
        X_test - Testing dataset predictors
        y_test - Testing dataset classes
     """
    recall_cons = []
    recall_refs = []
    bas = []

    for h in hp_array:
        hp_dict = {hparam:h}
        tree_model = DecisionTreeClassifier(hp_dict,random_state=66)
        tree = tree_model.fit(X_train,y_train)
        preds = tree.predict(X_test)
        recall_cons.append(mets.recall_score(y_test,preds,pos_label=2))
        recall_refs.append(mets.recall_score(y_test,preds,pos_label=1))
        bas.append(mets.balanced_accuracy_score(y_test,preds))  

    # plot metrics against minimum samples for a split
    fig, ax = plt.subplots(1,1,figsize=[15,11],facecolor="white")
    ax.set_facecolor("white")

    ax.plot(hp_array,recall_cons, 'g-')
    ax.plot(hp_array,bas,'b-')
    ax.plot(hp_array,recall_refs,'r-')
    ax.set_ylim(0,1)

    ax.legend(["Consent recall","Balanced accuracy", "Non-consent recall"],loc=2,fontsize=15,frameon=False)

    plt.xlabel(hparam, fontsize=15)

def forest_hparam_plot(hparam,hp_array,X_train,y_train,X_test,y_test):
    """ Plots balanced accuracy and recall for both classes against a list of hyperparameter values for a random forest classifier.
    
    Arguments:
        hparam - String with the name of the hyperparameter being tested
        hp_array - list of values of hparam being tested
        X_train - Training dataset predictors 
        y_train - Training dataset classes 
        X_test - Testing dataset predictors
        y_test - Testing dataset classes
     """
    recall_cons = []
    recall_refs = []
    bas = []

    for h in hp_array:
        hp_dict = {hparam:h}
        forest_model = RandomForestClassifier(hp_dict,random_state=66)
        forest = forest_model.fit(X_train,y_train)
        preds = forest.predict(X_test)
        recall_cons.append(mets.recall_score(y_test,preds,pos_label=2))
        recall_refs.append(mets.recall_score(y_test,preds,pos_label=1))
        bas.append(mets.balanced_accuracy_score(y_test,preds))  

    # plot metrics against minimum samples for a split
    fig, ax = plt.subplots(1,1,figsize=[15,11],facecolor="white")
    ax.set_facecolor("white")

    ax.plot(hp_array,recall_cons, 'g-')
    ax.plot(hp_array,bas,'b-')
    ax.plot(hp_array,recall_refs,'r-')
    ax.set_ylim(0,1)

    ax.legend(["Consent recall","Balanced accuracy", "Non-consent recall"],loc=2,fontsize=15,frameon=False)

    plt.xlabel(hparam, fontsize=15)

def boost_hparam_plot(hparam,hp_array,X_train,y_train,X_test,y_test):
    """ Plots balanced accuracy and recall for both classes against a list of hyperparameter values for a boosted forest classifier.
    
    Arguments:
        hparam - String with the name of the hyperparameter being tested
        hp_array - list of values of hparam being tested
        X_train - Training dataset predictors 
        y_train - Training dataset classes 
        X_test - Testing dataset predictors
        y_test - Testing dataset classes
     """
    recall_cons = []
    recall_refs = []
    bas = []

    for h in hp_array:
        hp_dict = {hparam:h}
        boosted_model =GradientBoostingClassifier(hp_dict,random_state=66)
        boosted = boosted_model.fit(X_train,y_train)
        preds = boosted.predict(X_test)
        recall_cons.append(mets.recall_score(y_test,preds,pos_label=2))
        recall_refs.append(mets.recall_score(y_test,preds,pos_label=1))
        bas.append(mets.balanced_accuracy_score(y_test,preds))  

    # plot metrics against minimum samples for a split
    fig, ax = plt.subplots(1,1,figsize=[15,11],facecolor="white")
    ax.set_facecolor("white")

    ax.plot(hp_array,recall_cons, 'g-')
    ax.plot(hp_array,bas,'b-')
    ax.plot(hp_array,recall_refs,'r-')
    ax.set_ylim(0,1)

    ax.legend(["Consent recall","Balanced accuracy", "Non-consent recall"],loc=2,fontsize=15,frameon=False)

    plt.xlabel(hparam, fontsize=15)

def knn_hparam_plot(hparam,hp_array,X_train,y_train,X_test,y_test):
    """ Plots balanced accuracy and recall for both classes against a list of hyperparameter values for a K nearest-neighbours classifier.
    
    Arguments:
        hparam - String with the name of the hyperparameter being tested
        hp_array - list of values of hparam being tested
        X_train - Training dataset predictors 
        y_train - Training dataset classes 
        X_test - Testing dataset predictors
        y_test - Testing dataset classes
     """

    recall_cons = []
    recall_refs = []
    bas = []

    for h in hp_array:
        hp_dict = {hparam:h}
        knn_model = KNeighborsClassifier(hp_dict)
        knn = knn_model.fit(X_train,y_train)
        preds =knn.predict(X_test)
        recall_cons.append(mets.recall_score(y_test,preds,pos_label=2))
        recall_refs.append(mets.recall_score(y_test,preds,pos_label=1))
        bas.append(mets.balanced_accuracy_score(y_test,preds))  

    # plot metrics against minimum samples for a split
    fig, ax = plt.subplots(1,1,figsize=[15,11],facecolor="white")
    ax.set_facecolor("white")

    ax.plot(hp_array,recall_cons, 'g-')
    ax.plot(hp_array,bas,'b-')
    ax.plot(hp_array,recall_refs,'r-')
    ax.set_ylim(0,1)

    ax.legend(["Consent recall","Balanced accuracy", "Non-consent recall"],loc=2,fontsize=15,frameon=False)

    plt.xlabel(hparam, fontsize=15)