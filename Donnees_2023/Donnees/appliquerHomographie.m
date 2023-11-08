% Calcul des coordonnees (xy2) des points (xy1)
% apres application d'une homographique H

function [xy2] = appliquerHomographie(H,xy1)

% Entrees :
%
% H   : matrice (3x3) de l'homographie
% xy1 :  matrice (nbPoints x 2) representant les coordonnees 
%       (colonne 1 : les x, colonne 2 : les y) 
%       des nbPoints points auxquels H est appliquee
%
% Sortie :
% xy2 : coordonnees des points apres application de l'homographie

% Nombre de points
% ... A completer ...
nb_points = size(xy1, 1);

% Construction des coordonnees homogenes pour appliquer l'homographie
% ... A completer ...
m1 = [xy1 ones(nb_points, 1)];

% Application de l'homographie
% ... A completer ...
m2 = (H * m1')';

% On retourne les coordonnees homogenes (x,y,1)
% Pour cela, il faut diviser par z
% Attention il ne faut garder que les deux premieres coordonnees
% ... A completer ...
m2 = m2 ./ m2(:, 3);
xy2 = m2(:, 1:2);
