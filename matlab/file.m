function file
clear all;
clc;
% listing = dir(fullfile('C:', 'Users', 'moon', 'Dropbox', '2014 summer research', '2014.05.26 Tn5 FAB 2nd 100um reactor', 'Left 1-4', '*.tif'));
overdir = 'C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\'   %%���� ������
underdir = 'Left 1-4\'    %%���� ������
listing = dir(fullfile(overdir, underdir, '*.tif'));
ImageNum = length(listing(not([listing.isdir])));        %%�̹����� ����

[sx,sx] = sort([listing.datenum],'descend');        %%��¥ ������������ �ֽ��� ���߿� ��������
listing=listing(sx);
listing.name

for i=1:ImageNum
    filename{i} = strcat(overdir,underdir, listing(i).name);
end
filename{1}