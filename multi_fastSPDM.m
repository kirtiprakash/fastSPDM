function [ Orte ] = multi_fastSPDM( d1 )

startImg = 100;
%d=uint8(stretch(d1(:,:,1:3:end)));
d=uint8(stretch(d1));
[~, ~, num_frames ] = size(d);

%%
BGF = 8; %factor for background calculation
% bgimage = double(d(:,:,startImg)); 
%startImg=10;
bgimage = double(mean(d(:,:,startImg:startImg+BGF-1),3));
meanbg = round(mean(bgimage(:)));
%% Image Handling
Orte=[];
Ortef=[];
for i = startImg + 1 : num_frames
    
    [diff,meanbg,bgimage] = addimagetobackground( bgimage,double(d(:,:,i)) ,BGF, meanbg,i);
    %create and subtract backgroundimage from image and calculate mean background
    %mesh(diff);figure(h);
    [Orte_slice,FitOrte] = clusterfind(diff,meanbg,i);
    %find Signal peaks and estimate meanvalues
    Orte = [Orte;Orte_slice];
    
    Ortef= [Ortef;FitOrte];
end


end

