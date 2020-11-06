%% settings
n=20;%subjects
r=5;%rois
t=50;%time points
s=2;%scans
subs=1:n;
%% randomly generated mri and behavioral data 
roi_data=rand(n,r,t,s); %range to 1
behavior=randi(100,1,n); % range to 100

%% average matrix: subjects x rois x time points
mean_time_series_persub_perroi=squeeze(nanmean(roi_data,4));

%% calculate temporal isc
%pairwise
pairwise_temporal_ISC=nan(n,n,r);
for roi=1:r
   pairwise_temporal_ISC(:,:,roi)=corr(squeeze(mean_time_series_persub_perroi(:,roi,:))',squeeze(mean_time_series_persub_perroi(:,roi,:))');
end

%leave-one-out
loo_temporal_ISC=nan(n,r); 
for ss=1:n
    for roi=1:r
        loo_temporal_ISC(ss,roi)=corr(squeeze(mean_time_series_persub_perroi(ss,r,:)),squeeze(nanmean(mean_time_series_persub_perroi(~ismember(subs,ss),r,:),1)));
    end
end

%% calculate dynamic isc
w=10; 
stepsize=10;

loo_dynamic_ISC=nan(n,r,5); 

idx=1:10:60;

for ss=1:n
    for roi=1:r
        for tt=1:t/w
            ave_window=mean_time_series_persub_perroi(:,:,idx(tt):idx(tt+1)-1);
            loo_dynamic_ISC(ss,roi,tt)=corr(squeeze(ave_window(ss,r,:)),squeeze(nanmean(ave_window(~ismember(subs,ss),r,:),1)));
        end
    end
end

figure; 
plot(squeeze(loo_dynamic_ISC(1,1,:)))
saveas(gcf,'sub1_roi1_tempISC.png')

%% calculate spatial isc
loo_spatial_ISC=nan(1,n);

for ss=1:n
    loo_spatial_ISC(n)=corr(squeeze(nanmean(mean_time_series_persub_perroi(s,:,:),3))',squeeze(nanmean(nanmean(mean_time_series_persub_perroi(~ismember(subs,ss),:,:),1),3))');
end

%% intra-subject correlation 
intrasubject_temporal_ISC=nan(n,r); 

for ss=1:n
    for roi=1:r
        intrasubject_temporal_ISC(ss,roi)=corr(squeeze(roi_data(ss,r,:,1)),squeeze(roi_data(ss,r,:,2)));
    end
end

%% inter-subject functional connectivity
loo_ISFC=nan(n,r,r);

for ss=1:n
    loo_ISFC(ss,:,:)=corr(squeeze(mean_time_series_persub_perroi(s,:,:))',squeeze(nanmean(mean_time_series_persub_perroi(~ismember(subs,ss),:,:),1))');
end

%% relationship between inter-subject representational similarity pattersn and behavior
behavioral_similarity=nan(n,n);
for ss=1:n
    for ss2=1:n
        behavioral_similarity(ss,ss2)=behavior(ss)-behavior(ss2);
    end
end
%I calculated similarity by subtracting the behavioral performance across
%all pairwise participants. This resulted in one number for each pair of
%participants. This measure of similarity tests how close each individual's
%score is to each other individual. 

%When you compare behavioral_similarity with
%pairwise_temporal_ISC, you are seeing whether the relationship between
%behavior across people is analagous to the relationship between neural
%activity across people. In this case, I don't expect there to be a
%relationship because the data were generated randomly

relationship_beh_tempISC=nan(r,1); 
for roi=1:r
    temp=squeeze(pairwise_temporal_ISC(:,:,roi));
    relationship_beh_tempISC(roi)=corr(temp(:),behavioral_similarity(:));
end

%the results seems to be random

%% Save all of the variables 
save('/Users/nicolehakim/Desktop/Maude/Documents/Classes/AdvancedTopicsNeuroimaging/variables.mat','relationship_beh_tempISC','behavioral_similarity',...
    'loo_ISFC','intrasubject_temporal_ISC','pairwise_temporal_ISC','loo_temporal_ISC','loo_dynamic_ISC','loo_spatial_ISC')














