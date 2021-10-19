function file
clear all;
clc;
% listing = dir(fullfile('C:', 'Users', 'moon', 'Dropbox', '2014 summer research', '2014.05.26 Tn5 FAB 2nd 100um reactor', 'Left 1-4', '*.tif'));
overdir = 'C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\'   %%상위 폴더명
underdir = 'Left 1-4\'    %%하위 폴더명
listing = dir(fullfile(overdir, underdir, '*.tif'));
ImageNum = length(listing(not([listing.isdir])));        %%이미지의 갯수

[sx,sx] = sort([listing.datenum],'descend');        %%날짜 오름차순으로 최신이 나중에 나오도록
listing=listing(sx);
listing.name

for i=1:ImageNum
    filename{i} = strcat(overdir,underdir, listing(i).name);
end
filename{1}