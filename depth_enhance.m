%% Initialization
img=im2double(depth);
NNeighbors=120;
count=1;
neighbors=zeros(121,2);
for i=-5:1:5
    for j = -5:1:5
        neighbors(count,1)=i;
        neighbors(count,2)=j;
        count=count+1;
    end
end
neighbors(61,:)=[];

%% Depth
[rows, col] = find(depth);
[rows2,col2]=find(~depth);
val=zeros(size(rows,1),1);
for i= 1:size(rows,1)
        val(i,1)=img(rows(i,1),col(i,1));
end
F=griddata(rows,col,val,rows2,col2,'nearest');
% Vq=F(rows2,col2);
for i= 1:size(rows2,1)
        img(rows2(i,1),col2(i,1))=F(i,1);
end


padDim=max(abs(neighbors));
sizeU=size(img);
uPad=padarray(img,padDim,'symmetric');
uStack=zeros([size(img) NNeighbors]);
for iNeighbor=1:NNeighbors
    xShift=neighbors(iNeighbor,1);
    yShift=neighbors(iNeighbor,2);
    uStack(:,:,iNeighbor)=...
        uPad(padDim+1+xShift:padDim+sizeU(1)+xShift,...
        padDim+1+yShift:padDim+sizeU(2)+yShift);
end
%% Color
color=rgb2ntsc(im2double(color));
sigma1=2;
sigma2=9;
sigma3=5;
sigma4=2;
NNeighbors=120;
count=1;
neighbors=zeros(121,2);
for i=-5:1:5
    for j = -5:1:5
        neighbors(count,1)=i;
        neighbors(count,2)=j;
        count=count+1;
    end
end
neighbors(61,:)=[];

neighbors_n=zeros(121,2);
count_n=1;
for i=-5:1:5
    for j = -5:1:5
        neighbors_n(count_n,1)=i;
        neighbors_n(count_n,2)=j;
        count_n=count_n+1;
    end
end
neighbors_n(61,:)=[];

uPadp=  padarray(color,[6 6],'symmetric');
uPadnp= padarray(uPadp,[1 1],'symmetric');



patch=  zeros(3,3,size(neighbors_n,1),3);

%for the bx
patch_dis=  zeros(3,3,size(neighbors_n,1));
patch_BX=  zeros(3,3,size(neighbors_n,1),3);
patch_add=  zeros(3,3,size(neighbors_n,1));
patch_bx_coef=  zeros(3,3,size(neighbors_n,1));
patch_count=1;

%for the color term
coloc=  zeros(size(neighbors_n,1),1);
% size(neighbors_n,1)

ar=zeros(size(color,1),length(color),size(neighbors_n,1));
for i=1:size(color,1)
    for j=1:size(color,2)
        for k=1:11
            for l=1:11
                if (k~=6&&l~=6)
                    %for bx, patch_dis is the distance coefficient, and BX is
                    %the distance between x(one point) and the patch centered
                    %at y
                    patch_dis(patch_count)=neighbors(patch_count,1)^2+neighbors(patch_count,2)^2;
                    patch_BX(:,:,patch_count,1)=color(i,j,1)-uPadnp(i-1+k:i-1+k+2,j-1+l:j-1+l+2,1);
                    patch_BX(:,:,patch_count,2)=color(i,j,2)-uPadnp(i-1+k:i-1+k+2,j-1+l:j-1+l+2,2);
                    patch_BX(:,:,patch_count,3)=color(i,j,3)-uPadnp(i-1+k:i-1+k+2,j-1+l:j-1+l+2,3);
                    %color term from now, colored patch difference
                    patch(:,:,patch_count,1)=uPadp(i:i+2,j:j+2,1)-uPadnp(i-1+k:i-1+k+2,j-1+l:j-1+l+2,1);
                    patch(:,:,patch_count,2)=uPadp(i:i+2,j:j+2,2)-uPadnp(i-1+k:i-1+k+2,j-1+l:j-1+l+2,2);
                    patch(:,:,patch_count,3)=uPadp(i:i+2,j:j+2,3)-uPadnp(i-1+k:i-1+k+2,j-1+l:j-1+l+2,3);
                    patch_count=patch_count+1;
                end
            end
        end
        patch_count=1;
  
        sigma2=sigma2^2;
        sigma3=sigma3^2;
        sigma4=sigma4^2;
  
        % For the bx
        % divided by the decay factor, square, sum, and combine together to
        % be expoentialed 
        patch_dis=patch_dis/((-2)*sigma3);
        
        patch_BX=patch_BX.^2;
        patch_add=patch_BX(:,:,patch_count,1)+patch_BX(:,:,patch_count,2)+patch_BX(:,:,patch_count,3);
        patch_add=patch_add/((-6)*sigma4);
        
        patch_bx_coef=bsxfun(@plus,patch_dis,patch_add);
        patch_bx_coef=exp(patch_bx_coef);       
        
        
        %caculate the norm
        %elementwise multiply the BX with 3 different channel patch first,
        %then get the norm(squared one), sum it
        %processed through the expoential
        m=1;
        a=patch_bx_coef(:,:,m).*patch(:,:,m,1);

        for m=1:size(neighbors_n,1)
            c=norm(patch_bx_coef(:,:,m).*patch(:,:,m,1))^2;
            d=norm(patch_bx_coef(:,:,m).*patch(:,:,m,2))^2;
            e=norm(patch_bx_coef(:,:,m).*patch(:,:,m,3))^2;
            f=c+d;
            f=f+e;

            coloc(m)=f;
        end
        coloc=coloc/((-6)*sigma2);
        coloc=exp(coloc);
        
        ar(i,j,:)=coloc(:);
        
        

    end
end
%% Final Calculation
S_x=zeros(sizeU);
for k=1:120
    S_x=S_x+exp(-(img-uStack(:,:,k)).^2/(2*sigma1.^2)).*ar(:,:,k);
end
a_xy=zeros(size(uStack));
for k=1:120
    a_xy(:,:,k)=exp(-(img-uStack(:,:,k)).^2/(2*sigma1.^2)).*ar(:,:,k)./S_x;
end
aded=zeros(sizeU);
for k=1:120
    aded=aded+uStack(:,:,k).*a_xy(:,:,k);
end
imshow(aded,[])