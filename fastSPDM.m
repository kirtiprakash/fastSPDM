function fastSPDM(varargin)
%%fastSPDM:
%   Detects signal peaks in the image stack by comparing them to the average pixel
%   value over time. The background is subtracted and the signal is fitted with a 
%   Gaussian esimator.
%
%
%params used from SPDM:
%   global d;             % input:  matrix (3D) with raw microscopy data
%   global startImg;      % input (int):  start evaluation with frame #
%   global Pixelsize;     % input: pixel pitch in the object space (in nm)
%   global Threshold;     % input: see function clusterfind
% 
%   global Orte;          % output: matrix with all localized signals
%
%%created by: Manfred Kirchgessner < Manfred.Kirchgessner@web.de>, 
%            Frederik Gruell <Frederik.Gruell@kip.uni-heidelberg.de>
%%


    %fprintf('Number of arguments is %d\n', nargin);

    if (nargin == 0)
        filename = 'unknown file';
    else
        filename = varargin{1};
    end

    global Orte;
    global Ortef;
    global d;
    global startImg;
    
    Orte = [];
    Ortef =[];
    
    if(isempty(startImg))
        startImg = 1;
    end
    
    [~, ~, num_frames ] = size(d);
    
    if(isempty(d))
        error('what the hell the file d is gone');
    end
 
    mybar = waitbar(0,'Localization of signals running...please wait', 'Name', [filename ' - progress']);
    %create a background profile over the first 16 images

    BGF = 8; %factor for background calculation   


    bgimage = double(d(:,:,startImg)); % double(mean(d(:,:,startImg:startImg+BGF-1),3)); 
    meanbg = round(mean(bgimage(:)));
    
    tic  

%% Image Handling

    for i = startImg + 1 : num_frames       

        [diff,meanbg,bgimage] = addimagetobackground( bgimage,double(d(:,:,i)) ,BGF, meanbg,i);  
        %create and subtract backgroundimage from image and calculate mean background
        %mesh(diff);figure(h);
        [Orte_slice,FitOrte] = clusterfind(diff,meanbg,i);
        %find Signal peaks and estimate meanvalues
        Orte = [Orte;Orte_slice];
        Ortef= [Ortef;FitOrte];

        if (mod(i,num_frames/200)==0)
           % surf(bgimage);figure(h);
            try               
                waitbar((i/num_frames),mybar,['Calculating image nr. ' num2str(i) ' of ' num2str(num_frames) '  -  ' num2str(size(Orte,1)) ' Points found.']);
            catch e
                rethrow(e);
            end
        end
    end
    
%% DIFF IMAGE
%     tic
%     for i=startImg+1:staple_size
% 
%         meanbg = mean(mean(double(d(:,:,i))));
%         diff = max(double(d(:,:,i)-d(:,:,i-1)),0);
% 
%         Orte_slice = clusterfind(diff,meanbg,i);
%         %find Signal peaks and estimate meanvalues
%         Orte = [Orte;Orte_slice]; 
%         
%         try 
%             waitbar((i/staple_size),mybar,['Calculating image nr. ' num2str(i) ' of ' num2str(staple_size) '. \n ' num2str(size(Orte,1)) ' Points found.']);
%         catch e
%             rethrow(e);
%         end       
%        
%     end
    
    
    fprintf('\n\n\n\n');
    fprintf('Done evaluating %s\n',filename); 
    fprintf('Execution time: %d\n\n', toc');        %time measurement
    fprintf('Signals found %g\n',size(Orte,1));
    if(isempty(Orte))
        mean_loc = NaN;
    else
        mean_loc = mean(mean(Orte(:,4:5),2))
    end
    fprintf('Mean localization accuracy:  %g\n\n', mean_loc)

    close(mybar);
    
   
 
        
