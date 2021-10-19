function [Brightsum Filename] = analysis(overdir, representative)
% dirs = regexp(genpath('C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor'),['[^;]*'],'match')


%% �Լ����� (R2013a ���� ���� Ȯ��) ��ġ ����
global Column;
global Row;
global Magnitude;                    %������ ���������

global MeanArea;
global MeanRadius;

%% 1. ���� �̸� �ҷ�����
% overdir = 'C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\'   %%���� ������
% underdir = 'Left 1-4\'    %%���� ������
listing = dir(fullfile(overdir, '*.tif'));
ImageNum = length(listing(not([listing.isdir])));        %%�̹����� ����
[sx,sx] = sort([listing.datenum],'descend');        %%��¥ ������������ �ֽ��� ���߿� ��������
listing=listing(sx);

%%filename �� ó�� ������ ���� ���� ���� �ֱ� ������ ���ϵ��� �̸��� ����
for i=1:ImageNum
    filename{i} = strcat(overdir, listing(i).name);
    Filename{i} = listing(i).name;
end

%% 2. ��ǥ �̹��� ���� ���� �� ����ũ �׸���
% f = imread('C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\Acquired-6.tif');
f=imread(representative);
[M, N, L] = size(f);

[L histed b degree stat MeanRadius MeanArea] = binarize(f);

%���׸���
figure(1)
subplot (2,1,1)
imshow(L);
hold on;
for k = 1: numel(stat)
%     rectangle('Position',[stat(x).Centroid(1)-MeanRadius,stat(x).Centroid(2)-MeanRadius,2*MeanRadius,2*MeanRadius],'Curvature',[1,1],'FaceColor','g');
    plot(stat(k).Centroid(1),stat(k).Centroid(2),'ro');
end

for k = 1:numel(stat)
    circle2(stat(k).Centroid(1), stat(k).Centroid(2),MeanRadius*Magnitude);
end
hold off;

%��ǥ�̹��� ������ ���� ����ũ ���
Mask=zeros(M,N);
for k=1:numel(stat)
    % Make the circle
    [xMat,yMat] = meshgrid(1:N,1:M);
    Mask = (sqrt((xMat-stat(k).Centroid(1)).^2 + (yMat-stat(k).Centroid(2)).^2)<=MeanRadius)|Mask;
end

%Degree ��ŭ �ݽð� �������� ����ũ�� ȸ��(�������� ����)
Mask = imrotate(Mask,degree,'nearest','crop');

%%�׵θ��� �ڸ���.
for i=1:M
    if sum(Mask(1,:)) == 0
        Mask(1,:) = [];
    end
    
    if sum(Mask(end,:)) == 0
        Mask(end,:) = [];
    end
end

for j=1:N
    if sum(Mask(:,1)) == 0
        Mask(:,1) = [];
        
    end
    
    if sum(Mask(:,end)) == 0
        Mask(:,end) = [];
    end
        
end
subplot(2,1,2)
imshow(Mask);


%% 3. Template matching for other images / Extract averaged brightness of each mask

figure(2)
for i=1:ImageNum
    try
        figure(3)
    fprintf('%s �������� ������::: \n',listing(i).name);
    image2ori = imread(filename{i});
    image2ori = im2double(image2ori);
    [image2M image2N]=size(image2ori);
    [image2 histed b2 degree2] = binarize(image2ori);
    %Degree ��ŭ �ݽð� �������� ����ũ�� ȸ��(�������� ����)
    if abs(degree2) >= 10
        Maskrotated=Mask;
    else
        Maskrotated = imrotate(Mask,-degree2,'nearest','crop');
    end
    
    [MaskM MaskN MaskL] = size(Maskrotated);
    g = dftcorr(image2,Maskrotated);
    [I,J] = find(g==max(g(:)));
%     subplot(4,5,i)
    imshow(histed);
    imagesc(image2ori);
    hold on;
    stat = regionprops(Maskrotated,'centroid');
    %�߽� �׸���
    Maskrotated =bwlabel(Maskrotated,4);
    Brightsum(i,1)=i;
    for k = 1: numel(stat)
        [xMat,yMat] = meshgrid(1:image2N,1:image2M);
        [xMask, yMask] = find(Maskrotated==k);
        Brightsum(i,k+1)=0;
        
        for m = 1:length(xMask)
            Brightsum(i,k+1) = Brightsum(i,k+1) + image2ori(xMask(m)+I,yMask(m)+J);
        end       

%         length(xMask)
%         Brightsum(i,k+1)
        if size(xMask,1) ==0
            Brightsum(i,k+1)=0;
        else
            Brightsum(i,k+1) = Brightsum(i,k+1)*65535/length(xMask);
        end
        
        A=plot(stat(k).Centroid(1)+J,stat(k).Centroid(2)+I,'ro');
        set(A,'LineWidth',2);
        
        image2ori(round(stat(k).Centroid(2)+I),round(stat(k).Centroid(1)+J));
%         round(stat(k).Centroid(2)+I),round(stat(k).Centroid(1)+J)
%         circle2(stat(k).Centroid(1)+J, stat(k).Centroid(2)+I,MeanRadius*Magnitude);
xc = stat(k).Centroid(1)+J;
yc = stat(k).Centroid(2)+I;
r = MeanRadius*Magnitude;
x = r*sin(-pi:0.1*pi:pi) + xc;
y = r*cos(-pi:0.1*pi:pi) + yc;
fill(x, y, 'r', 'FaceAlpha', 0.35)
%         Brightness(i,k+1) = sum(sum(image2ori(xMask+I,yMask+J)))/length(xMask);
%         pause(0.01)
    end
     fprintf('%s ���������� �߽�����. \n',listing(i).name);
    pause(0.01)
    hold off;
    catch
        fprintf('%s �������� ������!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!. \n',listing(i).name);
        continue
    end
end