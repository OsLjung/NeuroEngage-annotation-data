import re
from collections import defaultdict
import pprint as pp
import json
import os

def rec_dd():
    return defaultdict(rec_dd)
DATA = defaultdict(rec_dd)

def makeTime(timestamp, sec_msec, msec, sec_frames):
        return {'hhmmssddd':timestamp, 'sec':float (sec_msec), 'msec': int(msec), 'hhmmssff':sec_frames}


def processAnnotation(file):
    anotation_data=defaultdict(lambda: defaultdict(rec_dd))
    for line in open (file):
        splitline = line.split('\t')
        if len(splitline)== 16:
            tier = splitline[0]
            start_timestamp = splitline[2]
            start_sec_msec = splitline[3]
            start_msec = splitline[4]
            start_sec_frames = splitline[5]
            end_timestamp = splitline[6]
            end_sec_msec = splitline[7]
            end_msec = splitline[8]
            end_sec_frames = splitline[9]
            duration_timestamp = splitline[10]
            duration_sec_msec = splitline [11]
            duration_msec = splitline [12]
            duration_sec_frames = splitline[13]
            value = splitline[14].strip()
            filepath=splitline[15]

            start = round(float(start_sec_msec), 1)
            begin = makeTime(start_timestamp,start_sec_msec, start_msec, start_sec_frames)
            end = makeTime(end_timestamp, end_sec_msec, end_msec, end_sec_frames)
            duration = makeTime(duration_timestamp, duration_sec_msec, duration_msec, duration_sec_frames)
            

            anonymised_id = re.findall(r'id-\d\d',filepath)[0]
            anotation_data[anonymised_id]['anonymised_id']= anonymised_id 
            anotation_data[anonymised_id]['annotation'][start][tier]={'value' : value.strip(), 'begin':begin, 'end':end, 'duration':duration }
            
    return anotation_data

def mapping(mappingfile, tsvFile,):
    
    annotation_data = processAnnotation(tsvFile)
    for line in open (mappingfile):
        splitline = line.strip().split(',')
        anonymised_id = splitline[1]
        real_id = splitline[0]
        DATA [real_id] = dict(annotation_data[anonymised_id])
def conditions(file):
    for line in open(file):
        splitline = line.strip().split(';')
        filename = splitline[0]
        rating1 = splitline[1]
        rating2 = splitline[2]
        opinion_change = splitline[3]
        dilemma = splitline[4]
        engagement_condition = splitline[5]
        condition = splitline[6]

        operator_opinion = ''
        if dilemma == 'points_system' or 'arm_chip':
            operator_opinion = 'against'
        if dilemma == 'robot_judges' or 'tracking_app':
            operator_opinion = 'pro'
        if dilemma == 'dna_dating' or 'aging_pill':
            operator_opinion = 'neutral'
        else:
            operator_opinion = 'NA'

        subject_id = re.findall(r'sub-\d\d', filename)[0][-2:]
        run = re.findall(r'run-\d\d',filename )[0][-2:]

        real_id = filename.strip('.log')
        if real_id in DATA.keys():
            DATA[real_id]['rating1'] = (rating1)
            DATA[real_id]['rating2'] = (rating2)
            DATA[real_id]['opinion_change']=opinion_change
            DATA[real_id]['dilemma'] = dilemma
            DATA[real_id]['engagement_condition'] = engagement_condition
            DATA[real_id]['condition'] = condition
            DATA[real_id]['subject_id'] = subject_id
            DATA[real_id]['run'] = run
            DATA[real_id]['operator_opinion'] = operator_opinion

def writeToFile(folder):
    for name in DATA:
        if os.path.isdir(folder) == False:
            os.mkdir (folder)
        
        print(f'creating for {name}...')
        condition = ''
        try:
            engagement = '_'+DATA[name]['engagement_condition']
            if DATA[name]['condition'] == 'human':
                condition = '_human'
            if DATA[name]['condition'] == 'robot':
                condition = '_robot'
        except KeyError: 
            engagement = '_??'
            condition = '_??'

        
        filename = name+condition+engagement+'.json'
        DATA[name]['filename']=filename
        fp = open(f"{folder}/{filename}", 'w', encoding='utf-8')
        json.dump(DATA[name], fp, indent=4, ensure_ascii=False, sort_keys=True)
   
        
        
if __name__ == '__main__':
    mapping('mapping_human_human.csv', 'human-human-data.tsv')
    conditions('ratings_summary.csv')
    writeToFile('human-human')
    
    # mapping('mapping_human_robot.csv', 'human-robot-data.tsv')
    # conditions('ratings_summary.csv')
    # writeToFile('human-robot')
