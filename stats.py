import json
import os
from matplotlib import pyplot as plt
import seaborn as sns
import statistics
import numpy as np
import scipy.stats as stats
from collections import Counter
def filereader (dir):
    '''One of the few good parts of this program.
    it is a generator that will conveniently itterate over a directory
    of json files and pull out every event. and yiled it toghether with all the 
    conditional data
    Args: 
        dir (str): a file directory of Json files
    
    yileds
        dict: a ditcionary containing the event and all conditional data
    
    i recomend using the .get() function for dictonaries with each event yielded by this genereator
    it is useful if you need to filter for certain annotation types. 
    
    example 1:
        #.get will return None if the production_annotation tier is not pressent in the event
        # then you can check for None to filter out only production annotation data
        engagement = event.get('production_annotation', None)
        if engagement is not none:
            ----do something----
    
    example 2:
        #this will return a tuple if an event has a confidence annoation in it
        #that will contain the annotation value of that tier
        #the duration of that annotation (ie, the duration of production)
        #and the name of the dilemma for that session

        confidence = event.get('confidence_production', None)
        if engagement is not none:
            return (confidence[value], confidence[duration], confidence[dilemma])
    '''

    for file in os.scandir(dir):
        with open (file) as f:
            #print(file.name) # <-- when you inevetibly run into issues with a file, uncomment this and you will see what file causes the issue
            data = json.load(f)
            circumstances = {"anonymised_id": data['anonymised_id'],
                            "condition": data['condition'],
                            "dilemma": data['dilemma'],
                            "engagement_condition": data['engagement_condition'],
                            "opinion_change": data['opinion_change'],
                            "rating1": data['rating1'],
                            "rating2": data['rating2'],
                            "run": data['run'],
                            "subject_id": data['subject_id'],
                            "filename" : file.name}
            
            for event in data['annotation']:
                yield circumstances|data['annotation'][event]  

def histogram(dir):
    '''makes a histogram distribution of annotations'''
    values=[]
    for file in os.scandir(dir):
      
        with open(file.path) as f:
            data = json.load(f)
            for event in data['annotation']:
                try:
                    value = data['annotation'][event]["production_annotation"]['value']
                    if value == '':
                        print (data['anonumised_id'])
                        pass
                    values.append(value)
                    
                except KeyError:
                    pass
    print(Counter(values))
    
    values = [int(v) for v in values]
    mean = statistics.mean(values)
    median = statistics.median(values)
    sd = statistics.stdev(values)
    print(f'mean, {mean}\nmedian {median}\nstandard deviation {sd}')
    sns.histplot(values, bins=5, color='yellow', edgecolor='black').set(title='human-human')
    plt.ylabel('number')
    plt.xlabel('confidence')
    plt.show()


def corelateEngagement(dir):
    '''correlates engagement annoation with operator engagement condition
    and makes a plot'''
    low = []
    medium = []
    high =  []

    lowints= []
    mediumints = []
    highints = []
  
    for event in filereader(dir):
        engagement = event.get('production_annotation', None)
        if event['engagement_condition'] == 'low' and engagement is not None:
            low.append(event['production_annotation']['value'])
        if event['engagement_condition'] == 'medium' and engagement is not None:
            medium.append(event['production_annotation']['value'])
        if event['engagement_condition'] == 'high' and engagement is not None:
            high.append(event['production_annotation']['value'])
    
   
    for i, each in enumerate([low, medium, high]):
        new = []
        for number in each:
            if number in '12345' and number != '':
                new.append(int(number))
    
        if i == 0:
            lowints = new
        if i == 1:
            mediumints = new
        if i == 2:
            highints = new

    low_mid = stats.ttest_ind( mediumints,lowints)
    mid_high = stats.ttest_ind(highints,mediumints)
    print (f'low -> mid {low_mid}\nmid -> high {mid_high}')
    
    #print(lowints, mediumints, highints)
    data = [lowints, mediumints, highints]
    labels = ['Low engagement', 'Medium engagement', 'High engagement']

    # Create figure and axis
    fig = plt.figure(figsize=(10, 7))
    ax = fig.add_axes([0.1, 0.1, 0.8, 0.8])  # Add padding around edges

    # Create boxplot
    boxprops = dict(linestyle='-', linewidth=2, color='darkblue')
    medianprops = dict(linestyle='-', linewidth=2.5, color='red')
    meanprops = dict(marker='o', markerfacecolor='green', markersize=8)

    bp = ax.boxplot(data, patch_artist=True, labels=labels,
                    boxprops=boxprops, medianprops=medianprops,
                    showmeans=True, meanprops=meanprops)

    # Color each box
    colors = ['lightblue', 'lightgreen', 'lightpink']
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)

    # Add grid
    ax.yaxis.grid(True)
    ax.set_axisbelow(True)

    # Set labels and title
    ax.set_title('Distribution across operator engagement Levels', fontsize=16)
    ax.set_ylabel('participant engagement level', fontsize=12)
    ax.set_xlabel('operator engagement level', fontsize=12)

    # Customize ticks
    ax.tick_params(axis='x', labelsize=12)
    ax.tick_params(axis='y', labelsize=12)

    # Optionally set y-axis limits
    ax.set_ylim(0.5, 5.5)
    # Compute means of each group
    means = [np.mean(group) for group in data]

    # Plot line across means to show trend
    ax.plot([1, 2, 3], means, marker='D', color='black', linestyle='--', linewidth=2, label='Mean Trend')

    # Add legend to explain the line
    ax.legend()

    # Show the plot
    plt.show()

def correlateBackchannels(dir):
    '''correlates number of bachchannels with engagement annotation
    and plots it'''
    files = {}
    for event in filereader(dir):
        if event['filename'] not in files.keys():
            files[event['filename']] = {'NBackchannels': [], 'listEngagement':[]}
        
        if event.get('backchannels', None) is not None:
            files[event['filename']]['NBackchannels'].append(1)
        if event.get('production_annotation', None) is not None:
            if event['production_annotation']['value'] in '12345' and event['production_annotation']['value'] != '':
                value = int(event['production_annotation']['value'])
                files[event['filename']]['listEngagement'].append(value) 
    
    x =[]
    y =[]
    for file in files:
        x.append(sum(files[file]['NBackchannels']))
        y.append(statistics.mean(files[file]['listEngagement']))
    fig, ax = plt.subplots()
    ax.scatter(x,y)
    r, p = stats.pearsonr(x,y)
   
    ax = plt.gca()
    slope, intercept = np.polyfit(x, y, 1)
    # Plot the scatter plot and line of best fit
    ax.axline((0, intercept), slope=slope, color='red', label='line of best fit')
    plt.text(.9, .85, 'r={:.2f}'.format(r), transform=ax.transAxes)
    plt.text(.9, .8, 'p={:.2f}'.format(p), transform=ax.transAxes)
    plt.xlabel('Number of backchannels')
    plt.ylabel('Average engagement')
    plt.title('How backchannels correlate to engagement')
    plt.legend()
    plt.show()

def correlateOpinion(dir):
    '''correlates opinion change with engagement annotation 
    and plots it'''
    more_against = []
    more_pro = []
    no_change =  []

    ma_ints= []
    mp_ints = []
    nc_ints = []
  
    for event in filereader(dir):
        engagement = event.get('production_annotation', None)
        if event['opinion_change'] == 'more_pro' and engagement is not None:
            more_pro.append(event['production_annotation']['value'])
        if event['opinion_change'] == 'no_change' and engagement is not None:
            no_change.append(event['production_annotation']['value'])
        if event['opinion_change'] == 'more_against' and engagement is not None:
            more_against.append(event['production_annotation']['value'])
    
        
    for i, each in enumerate([more_against, no_change, more_pro]):
        new = []
        for number in each:
            if number in '12345' and number != '':
                new.append(int(number))
    
        if i == 0:
            ma_ints = new
        if i == 1:
            nc_ints = new
        if i == 2:
            mp_ints = new
    
    low_mid = stats.ttest_ind( ma_ints,nc_ints)
    mid_high = stats.ttest_ind(nc_ints, mp_ints)
    print (f'more against -> no change {low_mid}\nno change -> more pro {mid_high}')
    
    #print(lowints, mediumints, highints)
    data = [ma_ints, nc_ints, mp_ints]
    
    labels = ['More against', 'No change', 'More favorable']

    # Create figure and axis
    fig = plt.figure(figsize=(10, 7))
    ax = fig.add_axes([0.1, 0.1, 0.8, 0.8])  # Add padding around edges

    # Create boxplot
    boxprops = dict(linestyle='-', linewidth=2, color='darkblue')
    medianprops = dict(linestyle='-', linewidth=2.5, color='red')
    meanprops = dict(marker='o', markerfacecolor='green', markersize=8)

    bp = ax.boxplot(data, patch_artist=True, labels=labels,
                    boxprops=boxprops, medianprops=medianprops,
                    showmeans=True, meanprops=meanprops)

    # Color each box
    colors = ['lightpink', 'lightyellow', 'lightgreen']
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)

    # Add grid
    ax.yaxis.grid(True)
    ax.set_axisbelow(True)

    # Set labels and title
    ax.set_title('Engagement distribution relative to opinion change', fontsize=16)
    ax.set_ylabel('participant engagement level', fontsize=12)

    # Customize ticks
    ax.tick_params(axis='x', labelsize=12)
    ax.tick_params(axis='y', labelsize=12)

    # Optionally set y-axis limits
    ax.set_ylim(0.5, 5.5)
    # Compute means of each group
    means = [np.mean(group) for group in data]

    # Plot line across means to show trend
    ax.plot([1, 2, 3], means, marker='D', color='black', linestyle='--', linewidth=2, label='Mean Trend')

    # Add legend to explain the line
    ax.legend()

    # Show the plot
    plt.show()

def multiple_scatter_plot(dir, outfile):
    ''' correlates backchannels and engegement, and makes a color coded scatter plot
    with where every dot has a diferent color depending on operator engagement condition of that session'''
    file_dict = {}
    for event in filereader(dir):
        if event['filename'] not in file_dict.keys():
            file_dict[event['filename']] = {'values':[], 
                                        'backchannels': 0,
                                        'engagement_condition':event['engagement_condition'],
                                        'subject':event['subject_id'],
                                        'run':event['run']}
        engagement = event.get('production_annotation', None)
        
        backchannel = event.get('backchannels', None)
        
        if engagement is not None and engagement['value'] in ['1','2','3','4','5']: 
           
            file_dict[event['filename']]['values'].append(int(event['production_annotation']['value']))

        if backchannel is not None:
            file_dict[event['filename']]['backchannels'] += 1
        
        if engagement is not None and engagement['value'] not in ['1','2','3','4','5']:
            print(event['filename'], event["anonymised_id"])
    
    low_values = []
    medium_values = []
    high_values = []
    low_backchannels = []
    medium_backchannels = []
    high_backchannels = []
    csv_data = ''
    for item in file_dict.items():
        key, data = item
        avg_value = statistics.mean(data['values'])
        if data['engagement_condition'] == 'low':
            low_values.append(avg_value)
            low_backchannels.append(data['backchannels'])
        if data['engagement_condition'] == 'medium':
            medium_values.append(avg_value)
            medium_backchannels.append(data['backchannels'])
        if data['engagement_condition'] == 'high':
            high_values.append(avg_value)
            high_backchannels.append(data['backchannels'])
        csv_data+= f'{key};{data['subject']};{data['run']};{data['backchannels']};{avg_value};{data['engagement_condition']}\n'
    with open(outfile, 'w', encoding='utf-8') as f:
        f.write(csv_data)
    fig = plt.figure()
    ax1 = fig.add_subplot(111)


    ax1.scatter(low_backchannels, low_values, c='red', label='low engagement')
    ax1.scatter(medium_backchannels, medium_values, c='y', label='medium engagement')
    ax1.scatter(high_backchannels, high_values, c='green', label='high engagement')

    r, p = stats.pearsonr(low_backchannels,low_values)
   
    ax1 = plt.gca()
    slope, intercept = np.polyfit(low_backchannels, low_values, 1)
    ax1.axline((0, intercept), slope=slope, color='red')
    plt.text(.55, .95, 'low engagement r={:.2f}'.format(r), transform=ax1.transAxes)
    plt.text(.9, .95, 'p={:.2f}'.format(p), transform=ax1.transAxes)

    r, p = stats.pearsonr(medium_backchannels,medium_values)
   
    ax1 = plt.gca()
    slope, intercept = np.polyfit(medium_backchannels, medium_values, 1)
    ax1.axline((0, intercept), slope=slope, color='yellow')
    plt.text(.48, .9, 'medium engagement r={:.2f}'.format(r), transform=ax1.transAxes)
    plt.text(.9, .9, 'p={:.2f}'.format(p), transform=ax1.transAxes)

    r, p = stats.pearsonr(high_backchannels,high_values)
   
    ax1 = plt.gca()
    slope, intercept = np.polyfit(high_backchannels, high_values, 1)
    ax1.axline((0, intercept), slope=slope, color='green')
    plt.text(.54, .85, 'high engagement r={:.2f}'.format(r), transform=ax1.transAxes)
    plt.text(.9, .85, 'p={:.2f}'.format(p), transform=ax1.transAxes)
    
    plt.title('Amount of backchannels relative to average engagement level')
    plt.xlabel('number of backchannels')
    plt.ylabel('average engagement level')
    plt.legend()
    plt.show()

def pairedProdComp(dir):
    pairs = []
    current_time = 0
    backchannels = [0]
    engagements = []
    filename = ''
    for event in filereader(dir):
        if filename != event['filename']:
            current_time = 0
            filename = event['filename']
               
        engagement = event.get('production_annotation', None) 
        backchannel = event.get('backchannels', None)
       
        if engagement is not None and engagement['begin']['msec'] > current_time:
            pairs.append((engagements,backchannels))
            engagements = []
            backchannels = [0]
            current_time = engagement['begin']['msec']
            
        if engagement is not None:

            if engagement['value'] in ['1','2','3','4','5']:
                engagements.append(int(engagement['value']))
        if backchannel is not None:
            backchannels.append(1)

    
    x = []
    y = []
    z = Counter()
    for tup in pairs:
        a,b = tup
        
        if a != []:
            z[(a[0], sum(b))]+=1
            y.extend(a)
            x.append(sum(b))
   
    fig, ax = plt.subplots()
    a=[]
    b=[]
    size=[]
    for key in z:
        a.append(key[0])
        b.append(key[1])
        size.append(z[key])
    ax.scatter(b, a, s=size)
    r, p = stats.pearsonr(x,y)
   
    ax = plt.gca()
    slope, intercept = np.polyfit(x, y, 1)
    # Plot the scatter plot and line of best fit
    ax.axline((0, intercept), slope=slope, color='red', label='line of best fit')
    plt.text(.9, .85, 'r={:.2f}'.format(r), transform=ax.transAxes)
    plt.text(.9, .8, 'p={:.2f}'.format(p), transform=ax.transAxes)
    plt.xlabel('Number of backchannels immediately following production')
    plt.ylabel('engagement score of the production')
    plt.title('How backchannels correlate to engagement')
    plt.legend()
    plt.show()

def timeNormalised(dir, outfile):

    '''this one mekes a CSV file with each line coresponding to an exchange'''
    filedata = "subject;run;opinion1;opinion2;opinion_change;confederate condition;engagemnet_condition;engagement;backchannels;production_duration;comprehension_duration;total_duration;filename\n"
    for file in os.scandir(dir):
        with open (file) as f:
            data = json.load(f)
            condition = data['condition']
            engagement_condition=data['engagement_condition']
            opinion_change =  data['opinion_change']
            rating1 = int(data['rating1'])
            rating2 = int(data['rating2'])
            run = data['run']
            subject_id = data['subject_id']
            filename = file.name
            bch = [0]
            old_time = 0
            production_duration = 0
            data_line = ''
            value = ''


            for event in data['annotation']:
                
                engagement = data['annotation'][event].get('production_annotation', None)
                if engagement != None and engagement['begin']['msec'] > old_time and old_time != 0:
                    new_time = engagement['begin']['msec']
                    total_duration = new_time - old_time
                    comprehension = total_duration - production_duration
                    data_line += f"{subject_id};{run};{rating1};{rating2};{opinion_change};{condition};{engagement_condition};{value};{sum(bch)};{production_duration};{comprehension};{total_duration};{filename}\n"
                    bch = [0]
                if engagement is not None:
                    value = engagement['value']
                    old_time = engagement['begin']['msec']
                    production_duration = engagement['duration']['msec']

                backchannels = data['annotation'][event].get('backchannels', None)
                if backchannels is not None: 
                    bch.append(1)
            filedata += data_line
        with open (outfile, 'w', encoding='utf-8') as f:
            f.write(filedata)
def measureTime(dir):
    op_durs = []
    sub_durs = []
    old_sub_durs = []
    for file in os.scandir(dir):
       
        data = json.load(open(file))
        for event in data['annotation']:
            operator = data['annotation'][event].get('operator', None)
            engagement = data['annotation'][event].get('production_annotation',None)
            old_prod = data['annotation'][event].get('participant',None)
            if operator is not None:
                op_durs.append(int(operator['duration']['msec']))
            if engagement is not None:
                sub_durs.append(int(engagement['duration']['msec']))
            if old_prod is not None:
                old_sub_durs.append(int(old_prod['duration']['msec']))
    print(f'''subject durations new\t
            average: {statistics.mean(sub_durs)/1000}\t
            standard deviation: {statistics.stdev(sub_durs)/1000}''')
    print(f'''operator duration\t
            average: {statistics.mean(op_durs)/1000}\t
            standard deviation: {statistics.stdev(op_durs)/1000}''')
    print(f'''old subject durations duration\t
            average: {statistics.mean(old_sub_durs)/1000}\t
            standard deviation: {statistics.stdev(old_sub_durs)/1000}\n''')
if __name__ == "__main__":
    ## here is a hideous excuse for what bearly qualifies as an interface.
    ## bellow are all the functions in the program, as an argument, each take a directory where all the json files are stored
    ## for me that is either 'human-human' for human interaction or 'human-robot' for robot interactions. 
    ## you may run into errors, actually, you will almost certainly run into errors. Key errrors, when one file is missing a field of som kind
    ## notably subject 51 will cause this problem. since conditional data for them are absent
    ## i swear i'm a better programmer than this, but this was intendet to be something i would use once or twice and then discard. 
    
    #histogram('human-robot')
    #lineplot('human-human')
    #corelateEngagement('human-robot')
    #correlateBackchannels('human-human')
    #correlateOpinion('human-human')
    #multiple_scatter_plot('human-human')
    #pairedProdComp('human-human')
    #timeNormalised('human-human')
    measureTime('human-human')
    
    # multiple_scatter_plot('human-robot', 'production-comprehensioin-paired-robot.csv')
    # timeNormalised('human-robot', 'production-comprhension-paired-nomralised-robot.csv')
    