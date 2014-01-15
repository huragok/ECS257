function contourScatter(x, y, z)

plot3(x, y, z,'.-');

tri = delaunay(x, y);
plot(x,y,'.')

trisurf(tri, x, y, z);
axis equal;
axis vis3d
lighting phong
shading interp
colorbar EastOutside
view(2);

