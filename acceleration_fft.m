dateArrayLength = length(VarName1);
elapsedArray = zeros(dateArrayLength, 1);
timeArray = zeros(dateArrayLength, 1);
velX = zeros(dateArrayLength, 1);
velY = zeros(dateArrayLength, 1);
velZ = zeros(dateArrayLength, 1);
posX = zeros(dateArrayLength, 1);
posY = zeros(dateArrayLength, 1);
posZ = zeros(dateArrayLength, 1);

base = zeros(1, 1);
for i = 2:dateArrayLength
	j = i - 1;
	split1 = strsplit(char(VarName1(i)), ':');
	split2 = strsplit(char(VarName1(j)), ':');
	currTime = str2double(split1(3));
	prevTime = str2double(split2(3));
	if(i == 2)
		timeArray(1) = 0;
		base = prevTime;
	else
		timeArray(j) = prevTime - base;
	end;
	elapsedTime = currTime - prevTime;
	if(elapsedTime < 0.000)
		elapsedTime = (60.000 + currTime) - prevTime;
	end;
	
	xAcc = VarName2(i) - VarName2(j);
	yAcc = VarName3(i) - VarName3(j);
	zAcc = VarName4(i) - VarName4(j);
	
	mX = xAcc/elapsedTime;
	mY = yAcc/elapsedTime;
	mZ = zAcc/elapsedTime;

	bX = VarName2(j);
	bY = VarName3(j);
	bZ = VarName4(j);
	
	funX = @(x) mX*x + bX;
	funY = @(x) mY*x + bY;
	funZ = @(x) mZ*x + bZ;

	velX(j) = integral(funX, prevTime, currTime);
	velY(j) = integral(funY, prevTime, currTime);
	velZ(j) = integral(funZ, prevTime, currTime);

end;

	
for i = 2:dateArrayLength
	j = i - 1;
	split1 = strsplit(char(VarName1(i)), ':');
	split2 = strsplit(char(VarName1(j)), ':');
	currTime = str2double(split1(3));
	prevTime = str2double(split2(3));
	elapsedTime = currTime - prevTime;
	if(elapsedTime < 0.000)
		elapsedTime = (60.000 + currTime) - prevTime;
	end;
	
	xVel = velX(i) - velX(j);
	yVel = velY(i) - velY(j);
	zVel = velZ(i) - velZ(j);
	
	mX = xVel/elapsedTime;
	mY = yVel/elapsedTime;
	mZ = zVel/elapsedTime;

	bX = VarName2(j);
	bY = VarName3(j);
	bZ = VarName4(j);
	
	funX = @(x) mX*x + bX;
	funY = @(x) mY*x + bY;
	funZ = @(x) mZ*x + bZ;

	posX(j) = integral(funX, prevTime, currTime);
	posY(j) = integral(funY, prevTime, currTime);
	posZ(j) = integral(funZ, prevTime, currTime);
end;
	
timeMin = uint8(timeArray(1) - 1);
timeMax = uint8(timeArray(dateArrayLength-1) + 1);

figure;
plot(timeArray, posX, timeArray, posY, timeArray, posZ)
xlim([timeMin timeMax])
ylim auto
title('Relative Position in Three Dimensions')
xlabel('time (seconds)')
ylabel('Position');

fs = dateArrayLength;
L = dateArrayLength;

newX = fft(posX);
newY = fft(posY);
newZ = fft(posZ);

Px = abs(newX/L);
Py = abs(newY/L);
Pz = abs(newZ/L);

freqX = Px(1:L/2+1);
freqY = Py(1:L/2+1);
freqZ = Pz(1:L/2+1);

freqX(2:end-1) = 2*freqX(2:end-1);
freqY(2:end-1) = 2*freqY(2:end-1);
freqZ(2:end-1) = 2*freqZ(2:end-1);

freq = fs*(0:(L/2))/L;

figure;
plot(freq, freqX)
title('FFT of Relative Position in the X Dimension')
xlabel('Frequency')
ylabel('Intensity');

figure;
plot(freq, freqY)
title('FFT of Relative Position in the Y Dimension')
xlabel('Frequency')
ylabel('Intensity');

figure;
plot(freq, freqZ)
title('FFT of Relative Position in the Z Dimension')
xlabel('Frequency')
ylabel('Intensity');
