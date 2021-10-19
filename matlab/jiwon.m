function jiwon
clear all;
close all;
clc;

%% ������ ���� �ǵ帱 �κ�
% 26�� ����, overdir ���ٰ� �������ϵ��� �ִ� ������ ��θ� �Է�
% 41�� ����, imread ���ٰ� ��ǥ���� �̹��� ��ο� �����̸��� �Է�
% F5�� Ŭ������ �Լ� ����
% figure(5)â���� �뷫 0.5�ʸ���(�ļ��ɿ� ���� �ٸ�, ��������) ù ���Ϻ��� ������ ���ϱ��� �߽����� ���� �̴ϴ�.
% �߰��� ����ϰ� ������ ��Ʈ�� Ŀ�ǵ� â��, ���� Ctrl + C
% ���� ������ ���� ���� ��¥ �ð� ����(�ʴ���)�� �߽��ϴ�. ������ �ð���(�ʴ�������)�� ������ ���� ������ �� �ִ�����.
% ���ۼ��� ���α׷��Դϴ�. ���α׷��� �� �������ѵ�, ����ȭ �� �׷����������̽��� ���� �����ϰڽ��ϴ�.

%% �⺻����
% 1. �����߳��� ����(��ǥ)���� �߽�(���̶� ����, 8��)������ �Ÿ�, ��� ������ ���� ������ �Է¹ް�
% 2. �ش� �������� ������ ������� �о, filename(i), ������ ������ ���� ��ǥ�̹��� ���⸦ ����
% 3. Template matching �� �̿��Ͽ� �� �̹����� ���� �� ��Ī�� �Ǵ� ������ ã�� ǥ��
% 4. (������) filename(i)�� 8�� �߽ɿ��� ��չ�����*1.1��(����)�� �������� ���� ���� �׷���
% 5. (������) ���� ���ٺ��� [1 2 3 4 ; 5 6 7 8] �� ����ũ�� ����
% 6. (������) filename(i)���� ����ũ ���� 1������ 8������ ��� ��⸦ ���
% 7. (������) �������Ϸ� ��� [finlename(i) ����ũ(j) ��չ�� ��ո���]

%% �Լ����� (R2013a ���� ���� Ȯ��)
%%���� �̸� �ҷ�����
overdir = 'C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\'   %%���� ������
% underdir = 'Left 1-4\'    %%���� ������
listing = dir(fullfile(overdir, '*.tif'));
ImageNum = length(listing(not([listing.isdir])));        %%�̹����� ����

[sx,sx] = sort([listing.datenum],'descend');        %%��¥ ������������ �ֽ��� ���߿� ��������
listing=listing(sx);
listing.name

%%filename �� ó�� ������ ���� ���� ���� �ֱ� ������ ���ϵ��� �̸��� ����
for i=1:ImageNum
    filename{i} = strcat(overdir, listing(i).name);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=imread('C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\Acquired-6.tif');
%f=imread('C:\Users\moon\Dropbox\�������л�\�����̼�\����\2.jpg');
[M,N,L]=size(f);

%�Ϲ� ��Ȱȭ
histed=histeq(f);

%��Ʈ��Ʈ-��Ʈ��Ī ��ȯ
histed2=intrans(f,'stretch',mean2(im2double(f)),0.9);

%������ �� ������ ����
% fp=spfilt(histed2,'max',3,3);
%��� �� �������� ���
% fp=spfilt(histed2,'min',3,3);

%��Ȱȭ
% p = twomodegauss(0.15, 0.05, 0.75, 0.05, 1, 0.07, 0.002)
% histed2=histeq(f,p);
histed2=histeq(histed2);
%���͸� h ��
% h=fspecial('gaussian',30,15);
h=fspecial('gaussian',50,15);

%����þ� ���͸�
gh1=imfilter(histed2,h,'replicate');

%�׷��� ������Ȧ�� ����ġ������ ���� ����ȭ
gh=im2bw(gh1,1*graythresh(gh1));

%�󺧸�
L=bwlabel(gh,4);

%������Ʈ ���� ����
num=max(max(L)); %������Ʈ ����
ncol=4; %%input('Enter the number of colomuns : ');   %���ΰ���
nraw=2; %%input('Enter the number of raws : ');   %���ΰ���
n=ncol*nraw;    %�Է°� �� ����
fprintf('%f���� �ɷ����ڽ��ϴ�! \n',n)


%�󺧸��ؼ� n������ ������ n���� �ɶ����� ���� ���� ������ ���� �󺧸� ����
for i=1:num
    noe(i)= sum(sum(L==i));     %Number of dots(area)
end
noesort=sort(noe);

NumberOfRemoval=0;
if n < num
    for k=1:num-n   %���� ���� ������ ���� �󺧺���
        label=find(noe==noesort(k));   %index of min
        
        for i=1:size(L,1)
            for j=1:size(L,2)
                if L(i,j) == label
                    L(i,j)=0;
                end
            end
        end
        NumberOfRemoval=NumberOfRemoval+1;    
    end
    MeanArea=sum(noesort(num-n+1:end))/n;
    MeanRadius=sqrt(MeanArea/pi);
else
    MeanArea=sum(noesort)/num;
    MeanRadius=sqrt(MeanArea/pi);
end


% Ibw = im2bw(L);
% Ilabel = bwlabel(Ibw);
% stat = regionprops(Ilabel,'centroid');

L = bwlabel(L);
stat = regionprops(L,'centroid');


%���׸���

figure(1)
imshow(L); hold on;
for k = 1: numel(stat)
%     rectangle('Position',[stat(x).Centroid(1)-MeanRadius,stat(x).Centroid(2)-MeanRadius,2*MeanRadius,2*MeanRadius],'Curvature',[1,1],'FaceColor','g');
    plot(stat(k).Centroid(1),stat(k).Centroid(2),'ro');
end


%%�� ��ǥ �׸���
figure(3)
accum = 1;
for k=1:numel(stat)
    [x y] = getmidpointcircle(stat(k).Centroid(1), stat(k).Centroid(2), MeanRadius);
    Maskpixel(accum : accum + size(x) - 1,1) = x;
    Maskpixel(accum : accum + size(y) - 1,2) = y;
    accum = accum + size(x);
end
plot(Maskpixel(:,1),Maskpixel(:,2), 'r', 'LineWidth', 2);

%���׸���
Mask=zeros(M,N);
for k=1:numel(stat)
    % Make the circle
    [xMat,yMat] = meshgrid(1:N,1:M);
    Mask = (sqrt((xMat-stat(k).Centroid(1)).^2 + (yMat-stat(k).Centroid(2)).^2)<=MeanRadius)|Mask;
    
end
figure(2)
imshow(Mask)
%%%%    Least-squares fit ���� ���� �̹��� ������ ��� ���⸦ ����
%Initializing
xavg=0;
bnom=0;
bdenom=0;

%Compute x-average
for k=1:numel(stat)
    xavg=xavg+stat(k).Centroid(1);
end
xavg=xavg/numel(stat);

%6���� ��� 7���� ��� 8���� ��� ��� ������

%Compute b through least sqaures fit
for k=1:numel(stat)
    bnom=bnom+stat(k).Centroid(2)*(stat(k).Centroid(1)-xavg);
    bdenom=bdenom+stat(k).Centroid(1)*(stat(k).Centroid(1)-xavg);
end
b=bnom/bdenom;
degree=atand(b);

%Degree ��ŭ �ݽð� �������� ����ũ�� ȸ��(�������� ����)
% Mask = imrotate(Mask,degree,'nearest','crop');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%�̹���2�� �Ȱ��� ���⸦ ���ؼ� ���⸸ŭ ȸ������ �������� ����
%����ũ �̹����� �߶� ���ø� ��Ī�� �Ͽ� ���� ��ġ�� ã�´�
%�̹����� ����ŷ�Ͽ� 1~8�� �󺧸��� �Ѵ�.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���ο� �̹���2�� �ҷ���
[image2 b2 degree2] = binarize(filename{24}); %5��°�� 7�� ���¥����

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%����ũ�� ���⿡�� �̹���2�� ���⸦ �� ��ŭ ����ũ�� ȸ������ �̹���2�� ����ũ�� �����ϵ���

rotatedegree = degree - degree2;
%Degree ��ŭ �ݽð� �������� ����ũ�� ȸ��(�������� ����)
Maskrotated = imrotate(Mask,rotatedegree,'nearest','crop');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%���̳ʸ�ȭ
% Maskrotated=im2bw(Maskrotated);
% image2=im2bw(image2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g = dftcorr(image2,Maskrotated);
[I,J] = find(g==max(g(:)));

% image2rotate = imrotate(image2,degree2,'nearest','crop');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%����ũ �׵θ��� �ڸ���
%����ũ ����-�̹���2 ���� �� ������ŭ ����ũ�� ������ ���ø� ��Ī

%�̹���2�� ��� �ȼ��� ���Ѵ�
% image2=binarizetemp(image2);
% boundaries = bwboundaries(image2);
% numberOfBoundaries = size(boundaries);
% Mask_boundaries = bwboundaries(Mask);
% accum = 1;
%  for k = 1: numberOfBoundaries
%      thisBoundary = boundaries{k};
%      image2pixel(accum : accum + size(boundaries{k}(:,2)) - 1,1) = boundaries{k}(:,2);
%      image2pixel(accum : accum + size(boundaries{k}(:,1)) - 1,2) = boundaries{k}(:,1);
%      accum = accum + size((boundaries{k}(:,2)));
%  end
% size(Maskpixel);
% size(image2pixel);
%����ũ(Maskpixel)�� ���� ���� �̹���2(image2pixel)�� �°� ȸ����
% [d,Mask2,tr] = procrustes(image2pixel,Maskpixel,'Scaling',false);


figure(4)
subplot(2,2,1)
imshow(image2);

subplot(2,2,2)
imshow(Maskrotated);

subplot(2,2,3)
imshow(g);
hold on;
plot(J,I,'rx');
% imshow(Mask_boundaries);

subplot(2,2,4)
imshow(image2);
stat = regionprops(Maskrotated,'centroid');
%���׸���
hold on;
for k = 1: numel(stat)
%     rectangle('Position',[stat(x).Centroid(1)-MeanRadius,stat(x).Centroid(2)-MeanRadius,2*MeanRadius,2*MeanRadius],'Curvature',[1,1],'FaceColor','g');
    plot(stat(k).Centroid(1)+J,stat(k).Centroid(2)+I,'ro');
end
hold off;

% plot(image2pixel(:,1), image2pixel(:,2), 'g', 'LineWidth', 2);

figure(5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% �̹��� �ϳ��� �ҷ�����
for i=1:ImageNum
    [image2 b2 degree2] = binarize(filename{i});
    rotatedegree = degree - degree2;
    %Degree ��ŭ �ݽð� �������� ����ũ�� ȸ��(�������� ����)
    Maskrotated = imrotate(Mask,rotatedegree,'nearest','crop');
    g = dftcorr(image2,Maskrotated);
    [I,J] = find(g==max(g(:)));
    imshow(image2);
    stat = regionprops(Maskrotated,'centroid');
    %���׸���
    hold on;
    for k = 1: numel(stat)
        plot(stat(k).Centroid(1)+J,stat(k).Centroid(2)+I,'ro');
    end
    hold off;
    fprintf('%f��° ���������� �߽�����. \n',i);
    pause(0.3);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % 
% % for k=1:n
% %     label=find(noe==noesort(num+1-k));
% %     4
% 
% %     for i=1:size(L,1)
% %         for j=1:size(L,2)
% %             if L(i,j) == label
% %                 Layers(i,j,k)=k;
% %             end
% %         end
% %     end
% % end
% 
% 
% 
% % ��ǥ�̹��� ����, ���ø� ��Ī�� ���������� �̿��ؼ� ���� ������ ã��
% % 
% % 
% 
% % %������
% % [x,y]=minperpoly(gh,10);
% % B=gh;
% % b=boundaries(B,4,'cw');
% % b=b{1};
% % [M,N]=size(B);
% % xmin=min(b(:,1));
% % ymin=min(b(:,2));
% % bim=bound2im(b,M,N,xmin,ymin);
% 
% % figure(2)
% subplot(2,3,1)
% imshow(histed)
% title('���� ������׷� ��Ȱȭ')
% 
% subplot(2,3,2)
% imshow(histed2)
% title('��Ʈ��Ʈ-��Ʈ��Ī ��ȯ, ������׷� ��Ȱȭ')
% 
% subplot(2,3,3)
% imshow(gh1)
% title('������׷� ��Ȱȭ+����þ� ����')
% 
% subplot(2,3,4)
% imshow(L)
% title('�׷��� ����ġ�� 0 or 1 + �� �������� �󺧸� �Ǿ�����')
% 
% subplot(2,3,5)
% imhist(histed)
% title('original histogram')
% 
% subplot(2,3,6)
% imhist(histed2)
% title('equaled histogram')
% 
% %������׷�
% figure(5)
% subplot(2,2,1)
% imshow(histed)
% 
% subplot(2,2,2)
% imhist(histed)
% 
% subplot(2,2,3)
% imshow(histed2)
% 
% subplot(2,2,4)
% imhist(histed2)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%