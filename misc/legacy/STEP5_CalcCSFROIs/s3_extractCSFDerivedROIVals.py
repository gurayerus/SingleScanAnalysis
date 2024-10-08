import numpy as np
import pandas as pd
import os
import nibabel as nib
import sys
import numpy as np
import pickle

########################################
### Input args
prjName='ADNI'
prjDir='/cbica/projects/ADNI/Pipelines/ADNI_DLICV_2022'

#RADIUS = 2
RADIUS = 3
############################################################

######################### 
###  Other variables
inList= prjDir + '/Lists/' + prjName + '_MasterList_WithT1.csv'
inDir = prjDir + '/Protocols/CSF-RAVENS/'

templateRoiDir = prjDir + '/Templates/colin27_t1_tal_lin/DilatedROIs'
inPickle = templateRoiDir + '/Ind_DerivedROIs_Dil_' + str(RADIUS) + '.pickle'


oDir = prjDir + '/Protocols/CSF-DerivedROIs-Dil' + str(RADIUS)

######################### 
###  Main

if not os.path.exists(oDir):
    os.makedirs(oDir)

df = pd.read_csv(inList)

dictRoiInd = pickle.load(open(inPickle, "rb"))

dfOut = pd.DataFrame(index=dictRoiInd.keys(), columns=['RVals'])

#for i, tmpID in enumerate(df.SCID.tolist()[0:10]):
for i, tmpID in enumerate(df.SCID.tolist()):

    tmpID = str(tmpID)

    print('Subj ' + str(i) + ' : ' + tmpID)    

    csvSub = oDir + '/CSFROI_' + tmpID + '.csv'
    inImg = inDir + '/' + tmpID + '/' + tmpID + '_T1_LPS_dlicv_seg_ants-0.3_RAVENS_1.nii.gz'
    
    print(inImg)
    
    if os.path.exists(inImg):
        
        if not os.path.exists(csvSub):
            
            dfOut = pd.DataFrame(index=[tmpID], columns = dictRoiInd.keys())
            
            nii = nib.load(inImg)
            img = nii.get_fdata().flatten()

            for i,tmpKey in enumerate(dictRoiInd.keys()):
                dfOut.loc[tmpID, tmpKey] = img[dictRoiInd[tmpKey]].sum()

            dfOut.index.name = 'SCID'
            dfOut.to_csv(csvSub)
        
        else:
            print('Skip , exists')
