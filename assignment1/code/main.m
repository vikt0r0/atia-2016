%% Assignment 1

close all; clear all;

%% Get results

H = results(2,5,true);

%% Plot reference bitmap with reference correspondance points

figure;
hold on;
imagesc(H.img_ref_bm);
plot(H.pts_ref(2,:), H.pts_ref(1,:), 'oc');
hold off;

%% Plot reference bitmap with rectified correspondance points

figure;
hold on;
imagesc(H.img_ref_bm);
plot(H.pts_rect(2,:), H.pts_rect(1,:), 'oc');
hold off;

%% Plot reference image with rectified correspondance points

figure;
hold on;
imagesc(H.img_ref);
plot(H.pts_rect(2,:), H.pts_rect(1,:), 'oc');
hold off;

%% Plot rectified image bitmap with rectified correspondence points

figure;
hold on;
imagesc(H.img_rect_bm);
plot(H.pts_rect(2,:), H.pts_rect(1,:), 'oc');
hold off;