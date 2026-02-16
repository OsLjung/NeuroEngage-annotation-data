import json
import scipy
import os
import pprint as pp
import regex
import numpy

DATA = dict() #This dictionary holds the data before they are written to .mat files. it is sorted in the first order by file name.

def writeMat(out, jsonDir='human-human', matFiles='ons_durs_robotfmri/mat'):
    """This function compiles the data in three directories into onset and duration files for fMRI analysis.
        It is dependent on: 
            a directory of Json files containing annotation data extracted from ELAN combined with data on experimental conditions,
                named either "human-human" or "human-robot"
            a directory of log files from the fMRI experiment session used to synch the annotation times with the fMRI times named 'logfiles'
            a directory of older .mat files containing the times for silence and the fixation cross. 


    Args:
        out (str): the output directory to which the onset and  duration files shall be written.
                    Will create the directory if one does not already exist
        jsonDir (str, optional): the directory of json files containing annotation data. Defaults to 'human human'.
        matFiles (str, optional): the directory of matfiles from which silence and fixation cross shall be extracted.
                                 Defaults to 'ons_durs_robotfmri/mat'.
    """
    
    #the first loop itterates over the directory of json files to extract and manipulate annotation data.
    for file in os.scandir(jsonDir):
        
        #"names" are the names of the type of events to be studied. 
        #names =numpy.array(["production", "comprehension","turn_initiation","silence","fixation_cross",'low_eng', 'medium_eng', 'high_eng'], dtype=object)
        #names =numpy.array(["comprehension","turn_initiation","silence","fixation_cross",'low_eng', 'medium_eng', 'high_eng'], dtype=object)
        names =numpy.array(['prod_anat_medium', 'prod_anat_high', "comprehension","turn_initiation","silence","fixation_cross"], dtype=object)
        
        ######################################
        #TODO: make a numpy object array called "names" that contains the events you need to study in the desiered order
        #and comment out any other array of names.
        ######################################
        with open (file) as f:
            # matDict is the dictionary that will contain all the relevant data from one session, 
            # later it is added to DATA under the relevant file name
            # it contains three branches
            # names: the name of the events under study (list of strings)
            # onsets: the onset times for every event under study (list of lists)
            # durations: the durations for every event under study (list of lists)
            matDict = {'names': names,
                    'onsets':[],
                    'durations':[]
                } 
            
            # The follwoing ten lines goes into the logfiles directory
            # and extracts the delay between when the fMRI data starts and the annotation data.
            # The delay is added to every onset time to synch it with the fmri data
            filestem = regex.findall(r'sub-\d\d_run-\d\d', file.name)[0]
            fixation_start_found = False
            fixation_start = 0
            video_start = 0
            for line  in open (f'logfiles/{filestem}.log'):
                if line.split()[2:5] == ['fixation', 'cross', 'started'] and not fixation_start_found:
                    fixation_start_found = True
                    fixation_start = line.split()[0]  
                if line.split()[2:4] == ['video', 'started']:
                    video_start = line.split()[0]
            delay = float(video_start) - float(fixation_start) #the delay between annotation and fMRI data


            data = json.load(f)     # all the data loaded from the annotation Json files
            old_time = 0            # meta variable to keep track on where we are in the recording time-wise
            production_duration = 0 

            #the following variables are onsets and durations of different events expressind in milliseconds
            onsets_prod = numpy.float32([])     # the onsets of every production event
            onsets_comp = numpy.float32([])     # the onsets of every comprehension event
            
            onsets_low= numpy.float32([])       # the onsets of every production event annotated as low engagement
            onsets_medium = numpy.float32([])   # the onsets of every production event annotated as medium engagement
            onsets_high = numpy.float32([])     # the onsets of every production event annotated as high engagement
            
            durations_prod = numpy.float32([])  #the duration of every production event
            durations_comp = numpy.float32([])  #the duration of every comprehension event

            durations_low = numpy.float32([])   # the duration of every production event annotated as low engagement
            durations_medium = numpy.float32([])# the duration of every production event annotated as medium engagement
            durations_high = numpy.float32([])  # the duration of every production event annotated as high engagement
            
            ##########################
            #TODO: declare two numpy.float32 arrays for new type of event to be studied,
            # one for the onset times, and one for duration times
            #########################

            # this sub-loop goes over all the annotation data and extracts the times and durations of the annotations
            for event in data['annotation']:
                
                # for events relevant to production times, comprehension times and egnagement,
                # extract the 'production_annotation' tier
                
                # returns none if the event does not contain a production_annotation tier
                # otherwise it returns the annotation and time data of 
                engagement = data['annotation'][event].get('production_annotation', None)
                if engagement != None and engagement['begin']['msec'] > old_time: #checks to see if there is an engagement event, and if that event is after a previous event
                    
                    new_time = engagement['begin']['msec'] 

                    # onset of production starts when every production event begins (duh).
                    # onset of comprehension starts when every production event ends
                    # NOTE that the events are the onset and duration times are divided by 1000
                    # (to convert milliseconds to seconds)
                    # ... and the delay is added to the onset times
                    # (to synch with the fMRI data)
                    onsets_prod = numpy.append(onsets_prod, (new_time/1000)+delay) 
                    onsets_comp = numpy.append(onsets_comp, (engagement['end']['msec']/1000)+delay)
                    durations_prod = numpy.append(durations_prod, engagement['duration']['msec']/1000)
                    
                    # the following three if-statements seperates the annotation of engagement into three categories
                    # low, medium and high
                    # milliseconds are converted to seconds, and deley is added to onsets
                    if engagement['value'] in ['1', '2']:
                        onsets_low = numpy.append(onsets_low, (new_time/1000)+delay)
                        durations_low = numpy.append(durations_low, engagement['duration']['msec']/1000)
                    if engagement['value'] == '3':
                        onsets_medium = numpy.append(onsets_medium, (new_time/1000)+delay)
                        durations_medium = numpy.append(durations_medium, engagement['duration']['msec']/1000)
                    if engagement['value'] in ['4', '5']:
                        onsets_high = numpy.append(onsets_high, (new_time/1000)+delay)
                        durations_high = numpy.append(durations_high, engagement['duration']['msec']/1000)
                
                if engagement is not None: #moves the time forward to the next engagement event
                    old_time = engagement['begin']['msec']
                
                ######################
                #TODO check if the event is a backchannel event
                # and extract onsets and duration for the backchannel tier
                # tip: use the .get functions for dictionaries
                # example:
                #           backchannel = data['annotation'][event].get('backchannels', None)
                # this will make the backchannel variable either the data of a backchannel event
                # or None if it is not a backchannel event
                # you then check if backchannel != None and and only extract begin and duration times from events that pass that test.
                # remeber to add delay to onest times
                #####################
        
            #the following sub loop utalizes the onsets and durations of production events to define comprehension
            #comprehension is any time when the participant is not speaking
            compstart = 0 
            for prodOn, proddur in zip(onsets_prod, durations_prod):
                durations_comp = numpy.append(durations_comp, round(prodOn-compstart, 1))
                compstart = prodOn+proddur
            
            #in case there was no engagement events as a certain level
            #put a single event att time 0 with a duration of 0 seconds
            #this is a hack, but matlab will throw an error if onset and durations times are an empty array
            #so we add a virtual event with no duration to avoid that
            if onsets_low.size == 0:
                onsets_low = numpy.float32([0])
            if onsets_medium.size == 0:
                onsets_medium = numpy.float32([0])
            if onsets_high.size == 0:
                onsets_high = numpy.float32([0])
            
            if durations_low.size == 0:
                durations_low = numpy.float32([0])
            if durations_medium.size == 0:
                durations_medium = numpy.float32([0])
            if durations_high.size == 0:
                durations_high = numpy.float32([0])
            
            
            #Add all the onset and duration times to the correct branch of matDict
            #NOTE the order of operations matter here.
            #this must be done in an order corresponding to the order the "names" branch is written 
            #   example: if names are ["production", "comprehension","turn_initiation"]
            #   then production onsets must be appended to onsets FIRST,
            #   onsets of comprehension must be added SECOND
            #   and onsets of turn_initiation must be added THIRD.
            #   vis-a-vis for the order of duration times. 

            #matDict['onsets'].append(onsets_low)
            matDict['onsets'].append(onsets_medium)
            matDict['onsets'].append(onsets_high)
            #matDict['onsets'].append(onsets_prod)
            matDict['onsets'].append(onsets_comp)
            matDict['onsets'].append(numpy.float32([i-0.6 for i in onsets_prod])) #Turn initiation, defined as 0.6 seconds before onset of production
            matDict['onsets'].append(numpy.float32([])) #placeholder for silence onsets, added later
            matDict['onsets'].append(numpy.float32([])) #placeholder for fixation cross onsets, added later
            
            #matDict['durations'].append(durations_low)
            matDict['durations'].append(durations_medium)
            matDict['durations'].append(durations_high)
            #matDict['durations'].append(durations_prod)
            matDict['durations'].append(durations_comp)
            matDict['durations'].append([0.6]*len(onsets_prod)) #Turn initiations is always 0.6 long. adds a number of 0.6 equal to the number of production events
            matDict['durations'].append(numpy.float32([])) #placeholder for silence durations, added later
            matDict['durations'].append(numpy.float32([])) #placeholder for fixation cross durations, added later

            #######################
            #TODO   Comment-out any undesired types of events
            #       Comment-in any desired types of events
            #       Rearagne the order of operations to match the names branch
            #       Add any new events to be studied
            #######################
            
            
            filename = regex.findall(r'sub-\d\d_run-\d\d', data['filename'])[0] #filename extracted from the Json files
            #if not numpy.array_equal(onsets_medium, numpy.float32([0])) and not numpy.array_equal(onsets_high, numpy.float32([0])): #checks if there are no medium engagement events or high engagement events, and ignore those
            
            #matDict, now compleated, is added to the DATA dictionary, filed under a branch named after the filename+_exchange (e.g. "sub_01_run_01_exchange")
            #change the string concatonation if another naming convention for the .mat files are desired.
            DATA[filename+'_exchange'] = matDict 
            
       
    #The second loop itterates over old .mat files to extract onset and duration times for the fixation cross and silence  
    for file in os.scandir(matFiles):
        
        filename = regex.findall(r'sub-\d\d_run-\d\d', file.name) #regex identifies the log file corresponding to the annotation file

        #complicated nested dictionaries to extract the onset and durations of silence and fixation cross
        if filename != []: #check if the an old .mat file exists
            data = scipy.io.loadmat(file)
            silence_on = list(data['onsets'][0][3][0])
            silence_dur = list(data['durations'][0][3][0])
            fixation_cross_on = list(data['onsets'][0][4][0])
            fixation_cross_dur = list(data['durations'][0][4][0])
            
           
            try: #try to add silence and fixation cross

                #NOTE if you rearanged the order in which you added the onsets and durations to matDict so that fixation cross and silence placeholders are in new position
                # you need to update the index to which you write fixation cross and silence onsets and duration.
                # if you don't, you'll either overwrite an index containing something else, or not get silence and durations at all.
                DATA[filename[0]+'_exchange']['onsets'][4]=silence_on #adds onset of silence times to the placeholder array
                DATA[filename[0]+'_exchange']['onsets'][5]=fixation_cross_on #adds onset of fixation cross to the placeholder array
                DATA[filename[0]+'_exchange']['durations'][4]=silence_dur #adds duration of silence times to the placeholder array
                DATA[filename[0]+'_exchange']['durations'][5]=fixation_cross_dur #adds duration of duration times to the placeholder array
                
            except KeyError: #if they do not exist, just ignore it and move on
                pass
    # write the onsets and duration files to the output directory
    outputDir = out
    if not os.path.isdir(outputDir): #create the directory if it doesn't already exist
        os.mkdir(outputDir)
    
    #The third loop creates a .mat file for every first-order branch (filename) in the DATA dictionary
    for filename in DATA: 
        print(f'writing {filename}')
        scipy.io.savemat(outputDir+'/'+filename+'.mat', DATA[filename], appendmat=True, do_compression = True,)

if __name__ =='__main__':
     writeMat('testdir') 


