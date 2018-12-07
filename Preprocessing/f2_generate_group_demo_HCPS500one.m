clc;clear;

project_folder = '../NotGit/Projects/HCP-S500_one-FA';

subject_list = importdata(fullfile(project_folder, 'SubjectList_S500Release_one_n100.txt'));

demographics = readtable(fullfile(project_folder, 'S1200_demographics_Behavioral.csv'));

IDs_in_demographics = demographics.Subject;

output_group_csv = fullfile(project_folder, 'subject_cluster_measure', 'subject_group.csv');

%%
fid = fopen(output_group_csv, 'w') ;
fprintf(fid, '%s\n', 'SubjectID,GROUP') ;
for s_idx = 1:length(subject_list)
    sub_ID = subject_list(s_idx);
    
    disp(sub_ID);
    
    try
        idx = find(sub_ID == IDs_in_demographics);
    catch
        disp('invalid sub ID');
        continue;
    end
    
    subjectID = demographics.Subject(idx);
    
    gender = demographics.Gender(idx);
    gender = gender{1};
    if gender == 'F'
        group = '1';
    elseif gender == 'M'
        group = '2';
    end
    
    disp({subjectID, gender, group});
    
    fprintf(fid, '%s\n', [num2str(subjectID) ',', group]) ;
end
fclose(fid);

