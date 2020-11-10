#define MAXT 100

#define PI 3.1416



int hist = 2; //filter type --see MakeConvlFunc

int conv_start, conv_tot; /*conv_tot is the total time of the filter and

conv_start is the

beginning point of the filter

with respect to the time of the spike (i.e., it is

zero for the PSP filter, but -3*stddev for a

Gaussian filter */

int binw = 10; //bin width for regular histogram

int stddev = 10; //standard deviation for Gaussian filter

int growth = 1; //growth rate of PSP filter

int decay = 20; //decay rate of PSP filter

float convf[MAXT]; /* array that contains the values of the convolution filter

just make sure big enough for the time length of filter

which is conv_tot and depends on filter variables such as

decay rate */



/***** this function makes the convolution filter **************************/

void MakeConvlFunc(void)

{

register int i;

float temp;



for(i=0; i<MAXT; i++) convf[i]=0; //initialize



/* this part is for bin histogram */

if(hist==0){

conv_start=-binw/2;

conv_tot=binw;

for(i=0; i<conv_tot; i++)

convf[i]=1000.0/binw;

}

/* this part is to convolve with Gaussian filter */

else if(hist==1){

conv_start=-3*stddev;

conv_tot=6*stddev+1;

for(i=0; i<conv_tot/2+1; i++)

convf[-conv_start+i]=convf[-conv_start-i]=

(1000/(stddev*sqrt(2*PI)))*exp(-0.5*pow((float)i/stddev,2.0));

}

/* this part is to convolve with PSP filter */

else if(hist==2){

conv_start=0;

//the PSP function is pretty much back at zero by the time time=4*decay

conv_tot=4*decay;

for(i=1; i<conv_tot+1; i++){

convf[i-1]=(1-exp(-(float)i/growth))*exp(-(float)i/decay);

temp+=convf[i-1];

}

for(i=0; i<conv_tot; i++)

convf[i]=1000.0*convf[i]/temp;

}

}



/*** this function just shows a simplistic example of how to use the filter ****/

void ConvolveData(void)

{

register int i, j;

int t;



/* this function assumes you have an array spk_t[] that holds the times

of "num_spks" spike occurences.

The spike density function is spkd[TOTTIME]

*/



for(i=0; i<num_spks; i++){

t = spk_t[i];

if(t < -(conv_tot+conv_start)) continue;

else if(t > (TOTTIME-conv_start)) break;

for(j=0; j<conv_tot; j++)

if((t+j+conv_start)>=0 && (t+j+conv_start)<TOTTIME)

spkd[t+j+conv_start] += convf[j];

}

}