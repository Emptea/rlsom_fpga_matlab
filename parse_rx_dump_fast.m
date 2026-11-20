function [headers, iq] = parse_rx_dump_fast(filename)
% headers: 8 x N struct (CH0...CH7); iq: 8 x 232 x N complex single
info = dir(filename);
assert(~isempty(info), 'File not found: %s', filename);
r = mod(info.bytes,65);
assert(r==0 || r==64, 'File size is incompatible with 64 HEX characters per line.');
L = (info.bytes + (r==64))/65;
N = floor(L/234);

headers = repmat(struct('marker',uint32(0),'counter',uint32(0)),8,N);
iq = complex(zeros(8,232,N,'single'));

map = 255*ones(256,1,'uint8');
map(double('0':'9')+1) = uint8(0:9);
map(double('a':'f')+1) = uint8(10:15);
map(double('A':'F')+1) = uint8(10:15);

fid = fopen(filename,'rb');
assert(fid>=0, 'Cannot open file: %s',filename);
cleaner = onCleanup(@() fclose(fid));

fprintf('Parsing:   0.0%%');
tic;

for first = 1:32:N
    nb = min(32,N-first+1);
    rows = 234*nb;
    buf = fread(fid,65*rows,'*uint8');    
    buf = reshape(buf,65,rows);   
    hex = buf(1:64,:);
    nib = map(double(hex)+1);
    nib = reshape(uint16(nib),4,16,rows);
    w = bitor(bitor(bitshift(nib(1,:,:),12),bitshift(nib(2,:,:),8)), ...
              bitor(bitshift(nib(3,:,:),4),nib(4,:,:)));
    w = reshape(w,2,8,234,nb);
    marker = reshape(uint32(w(1,8:-1:1,1,:))*65536 + uint32(w(2,8:-1:1,1,:)),8,nb);
    counter = reshape(uint32(w(1,8:-1:1,2,:))*65536 + uint32(w(2,8:-1:1,2,:)),8,nb);
    
    
    idx = first:first+nb-1;
    h = num2cell(marker);
    c = num2cell(counter);
    [headers(:,idx).marker] = h{:};
    [headers(:,idx).counter] = c{:};

    s = reshape(typecast(w(:),'int16'),2,8,234,nb);
    re = reshape(s(2,8:-1:1,3:234,:),8,232,nb);
    im = reshape(s(1,8:-1:1,3:234,:),8,232,nb);
    iq(:,:,first:first+nb-1) = complex(single(re),single(im));

    progress = 100 * (first + nb - 1) / N;
    fprintf('\b\b\b\b\b\b%5.1f%%', progress);
end
fprintf('\nCompleted in %.2f s\n', toc(t));
end
