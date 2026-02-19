extn
====

Folder contains valuesModelExtn files.

valuesModelExtn should be used to modify only few params from the pre-defined valuesModel for some custom cases. 

Naming convention for the extension models,
    
    valuesModelExtn<extn_code><base_value>
    
    E.g. valuesModelExtnNF.yaml 
           extn_code is N, unique code to identify the extension yaml
           base_value is F, from which it is extended i.e valuesModelF.yaml

         valuesModelExtnXDefault.yaml 
           extn_code is X, unique code to identify the extension yaml
           base_value is Default, from which it is extended i.e default values.yaml