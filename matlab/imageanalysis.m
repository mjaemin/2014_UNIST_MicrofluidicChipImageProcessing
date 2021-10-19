function imageanalysis(motherfolder,representation)
%% �⺻����
% 1. ���� ���� ���� ���� ������ �˻��Ͽ� nameFolds{i} �� ����
% 2. �� ���� �������� ������ ������� �о, filename(i) �� ����
% 3. �����߳��� ����(��ǥ)���� �߽�(���̶� ����, 8��)������ �Ÿ�, ��� ������ ���� ������ �Է� 
% 4. ��ǥ ������ ���⸦ �������� ���� ��, �׵θ��� �߶�.(����ũ ����)
% 5. �м��ϰ��� �ϴ� �̹����� ���⸦ �м��Ͽ� ����ũ�� �ش� ���⿡ �°� ȸ��.
% 6. Template matching �� �̿��Ͽ� ����ũ�� �̹����� ���� �� ��Ī�� �Ǵ� ������ ã�� ����ŷ�� ���� ��� ��� ����
% 7. ���� �Ʒ������� ������ ������ ������� 1~8���� ��� Brightness �� ���.
% 8. �������Ϸ� ���

%% ����
% Column �� Row �� Magnitude ���� �Է��Ѵ�.
% �Ʒ��� ���� ������� ��ǥ�̹��� ��θ� �Է��Ѵ�
% imageanalysis('C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\','C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\Acquired-6.tif')
% ���� ������ Brightness.xls �������� ����.
% �ڼ��� �۵������� analysis.m ���� ����.
% Undefined function 'imageanalysis' for input arguments of type... ������ ���
% �����Ͽ��� F5 �ѹ� ������ change folder ��, Ŀ�ǵ忡 �ٽ� �Է�.

global MeanArea;
global MeanRadius;
global Magnitude;


d = dir(motherfolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
excel = strcat(motherfolder,'brightness.xls');

%% 4. �������Ϸ� ���
for i=1:length(nameFolds)
    [Brightsum Filename]=analysis(strcat(motherfolder, nameFolds{i},'\'),representation);
    xlswrite(excel,{nameFolds{i} '1' '2' '3' '4' '5' '6' '7' '8'},nameFolds{i});
    xlswrite(excel,Brightsum,nameFolds{i},'A2');
    xlswrite(excel,Filename',nameFolds{i},'A2');
    fprintf('%d ��° ��� ��. \n',i);
end
xlswrite(excel,...
    {'position' '2' '4' '6' '8';'' '1' '3' '5' '7';'���� �Ʒ������� 1,2,3...������ ������' '' '' '' '';...
    'MeanRadius' num2str(MeanRadius) '' '' '';'MeanArea' num2str(MeanArea) '' '' '';'Magnitude' num2str(Magnitude) '' '' ''},'howtosee');

fprintf('���� ���� ��� ��. \n');