clear all;
close all;

% Lecture des images
Im1 = imread('tournesols1.pgm');
Im2 = imread('tournesols2.pgm');
Im3 = imread('tournesols3.pgm');
Im1_coul = imread('tournesols1.jpg');
Im2_coul = imread('tournesols2.jpg');
Im3_coul = imread('tournesols3.jpg');
 
% Affichage des deux premières images en niveaux de gris
figure;
affichage_image(Im1,'Image 1',1,2,1);
affichage_image(Im2,'Image 2',1,2,2);

% Choix des parametres
TailleFenetre = 15;
NbPoints = 150 ;
k = 0.05;
seuil = 0.75;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detection des points d'interet avec Harris %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A DECOMMENTER POUR OBSERVER LA DETECTION DE HARRIS
[XY_1,Res_1] = harris(Im1,TailleFenetre,NbPoints,k);
[XY_2,Res_2] = harris(Im2,TailleFenetre,NbPoints,k);
figure;
affichage_POI(Im1,XY_1,'POI Image 1',1,2,1);
affichage_POI(Im2,XY_2,'POI Image 2',1,2,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Appariement des points d'interet %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A DECOMMENTER POUR OBSERVER LA MISE EN CORRESPONDANCE 
% avec/sans verification des contraintes
[XY_C1,XY_C2] = apparier_POI(Im1,XY_1,Im2,XY_2,TailleFenetre,seuil);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimation (et verification) de l'homographie %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A DECOMMENTER QUAND HOMOGRAPHIE AURA ETE COMPLETEE
H = homographie(XY_C1,XY_C2);

%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcul de la mosaique %
%%%%%%%%%%%%%%%%%%%%%%%%%
% A DECOMMENTER QUAND HOMOGRAPHIE AURA ETE VALIDEE
Imos = mosaique(Im1,Im2,H);
figure; 
affichage_image(uint8(Imos),'Mosaique obtenue a partir des 2 images initiales',1,1,1);
% SAUVEGARDE DE LA MOSAIQUE A DEUX IMAGES
imwrite(uint8(Imos),'mosaique2.pgm');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 2 pour la reconstruction                %
% A DECOMMENTER QUAND MOSAIQUEBIS AURA ETE ECRITE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Imosbis = mosaiquebis(Im1,Im2,H);
figure; 
affichage_image(uint8(Imosbis),'Mosaique obtenue a partir des 2 images initiales (version 2)',1,1,1);
% SAUVEGARDE DE LA MOSAIQUE A DEUX IMAGES VERSION 2
imwrite(uint8(Imosbis),'mosaique2_bis.pgm');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 3 pour la reconstruction avec les couleurs R, G et B %
% A DECOMMENTER QUAND MOSAIQUECOUL AURA ETE ECRITE             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Imoscoul, ~] = mosaiquecoul(Im1_coul,Im2_coul,H);
figure;
affichage_image(uint8(Imoscoul),'Mosaique obtenue a partir des 2 images couleur initiales (version 2)',1,1,1);
% SAUVEGARDE DE LA MOSAIQUE A DEUX IMAGES EN COULEUR VERSION 2
imwrite(uint8(Imoscoul),'mosaique2_coul.pgm');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 4 pour la reconstruction avec 3 images %  
% en couleurs et/ou en niveaux de gris           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detection des points d'interet avec Harris dans la 3eme image %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[XY_3,Res_3] = harris(Im3,TailleFenetre,NbPoints,k);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Appariement des points d'interet entre les images 2 et 3 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seuil = 0.9;
[XY_C2bis, XY_C3] = apparier_POI(Im2,XY_2,Im3,XY_3,TailleFenetre,seuil);

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimation de l'homographie entre les images 2 et 3 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
H2 = homographie(XY_C2bis, XY_C3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcul de la mosaique entre les images 2 et 3 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Imoscoul2, ~] = mosaiquecoul(Im2_coul, Im3_coul, H2);
figure;
affichage_image(uint8(Imoscoul2),'Mosaique obtenue a partir des 2 images couleur initiales (version 4)',1,1,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detection des points d'interet avec Harris dans la mosaique   % 
% entre les images 2 et 3                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Imos2 = rgb2gray(uint8(Imoscoul2));
[XY_mos2,Res_mos2] = harris(Imos2,TailleFenetre,NbPoints,k);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Appariement des points d'interet entre la premiere image % 
% et la mosaique des images 2 et 3                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seuil = 0.8;
[XY_Cmos2, XY_C1bis] = apparier_POI(Imos2,XY_mos2,Im1,XY_1,TailleFenetre,seuil);
%[XY_C1bis, XY_Cmos2] = apparier_POI(Im1,XY_1,Imos2,XY_mos2,TailleFenetre,seuil);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimation de l'homographie entre la premiere image      % 
% et la mosaique des images 2 et 3                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nb_iteration = 10;
distance_best = Inf;
for i = 1:nb_iteration
    i
    perm = randperm(size(XY_Cmos2, 1));
    idx = perm(1:6);
    H3 = homographie(XY_Cmos2(idx,:), XY_C1bis(idx,:));
    %H3 = homographie(XY_C1bis(idx,:), XY_Cmos2(idx,:));
    [~, distance] = mosaiquecoul(uint8(Imoscoul2), Im1_coul, H3);
    %[~, distance] = mosaiquecoul(Im1_coul, uint8(Imoscoul2), H3);
    if distance_best > distance
        distance_best = distance;
        best_H = H3;
        idx_best = idx;
    end
end

[Imoscoul1, ~] = mosaiquecoul(uint8(Imoscoul2), Im1_coul, best_H);
%[Imoscoul1, ~] = mosaiquecoul(Im1_coul, uint8(Imoscoul2), best_H);

% Affichage de l'image reconstruite
figure;
affichage_image(uint8(Imoscoul1),'Mosaique obtenue a partir des 3 images couleur initiales',1,1,1);
% SAUVEGARDE DE LA MOSAIQUE A DEUX IMAGES EN COULEUR VERSION 2
imwrite(uint8(Imoscoul1),'mosaique_3imgs_coul.pgm');

