/*
* NeuQuant Neural-Net Quantization Algorithm
* ------------------------------------------
* 
* Copyright (c) 1994 Anthony Dekker
* 
* NEUQUANT Neural-Net quantization algorithm by Anthony Dekker, 1994. See
* "Kohonen neural networks for optimal colour quantization" in "Network:
* Computation in Neural Systems" Vol. 5 (1994) pp 351-367. for a discussion of
* the algorithm.
* 
* Any party obtaining a copy of these files from the author, directly or
* indirectly, is granted, free of charge, a full and unrestricted irrevocable,
* world-wide, paid up, royalty-free, nonexclusive right and license to deal in
* this software and documentation files (the "Software"), including without
* limitation the rights to use, copy, modify, merge, publish, distribute,
* sublicense, and/or sell copies of the Software, and to permit persons who
* receive copies from any such party to do so, with the only requirement being
* that this copyright notice remain intact.
*/

/*
* This class handles Neural-Net quantization algorithm
* @author Kevin Weiner (original Java version - kweiner(at)fmsware.com)
* @author Thibault Imbert (AS3 version - bytearray.org)
* @version 0.1 AS3 implementation
*/

package org.alivepdf.images.gif.encoder;

import flash.errors.Error;

import flash.utils.ByteArray;

class NeuQuant
{
    
    private static var netsize : Int = 256;  /* number of colours used */  
    
    /* four primes near 500 - assume no image has a length so large */
    /* that it is divisible by all four primes */
    
    private static var prime1 : Int = 499;
    private static var prime2 : Int = 491;
    private static var prime3 : Int = 487;
    private static var prime4 : Int = 503;
    private static var minpicturebytes : Int = (3 * prime4);
    
    /* minimum size for input image */
    /*
		* Program Skeleton ---------------- [select samplefac in range 1..30] [read
		* image from input file] pic = (unsigned char*) malloc(3*width*height);
		* initnet(pic,3*width*height,samplefac); learn(); unbiasnet(); [write output
		* image header, using writecolourmap(f)] inxbuild(); write output image using
		* inxsearch(b,g,r)
		*/
    
    /*
		* Network Definitions -------------------
		*/
    
    private static var maxnetpos : Int = (netsize - 1);
    private static var netbiasshift : Int = 4;  /* bias for colour values */  
    private static var ncycles : Int = 100;  /* no. of learning cycles */  
    
    /* defs for freq and bias */
    private static var intbiasshift : Int = 16;  /* bias for fractions */  
    private static var intbias : Int = (1 << intbiasshift);
    private static var gammashift : Int = 10;  /* gamma = 1024 */  
    private static var gamma : Int = (1 << gammashift);
    private static var betashift : Int = 10;
    private static var beta : Int = (intbias >> betashift);  /* beta = 1/1024 */  
    private static var betagamma : Int = (intbias << (gammashift - betashift));
    
    /* defs for decreasing radius factor */
    private static var initrad : Int = (netsize >> 3);  /*
	                                                         * for 256 cols, radius
	                                                         * starts
	                                                         */  
    
    private static var radiusbiasshift : Int = 6;  /* at 32.0 biased by 6 bits */  
    private static var radiusbias : Int = (1 << radiusbiasshift);
    private static var initradius : Int = (initrad * radiusbias);  /*
	                                                                   * and
	                                                                   * decreases
	                                                                   * by a
	                                                                   */  
    
    private static var radiusdec : Int = 30;  /* factor of 1/30 each cycle */  
    
    /* defs for decreasing alpha factor */
    private static var alphabiasshift : Int = 10;  /* alpha starts at 1.0 */  
    private static var initalpha : Int = (1 << alphabiasshift);
    private var alphadec : Int = 0;  /* biased by 10 bits */
    
    /* radbias and alpharadbias used for radpower calculation */
    private static var radbiasshift : Int = 8;
    private static var radbias : Int = (1 << radbiasshift);
    private static var alpharadbshift : Int = (alphabiasshift + radbiasshift);
    
    private static var alpharadbias : Int = (1 << alpharadbshift);
    
    /*
		* Types and Global Variables --------------------------
		*/
    
    private var thepicture : ByteArray;  /* the input image itself */  
    private var lengthcount : Int = 0;  /* lengthcount = H*W*3 */
    private var samplefac : Int = 0;  /* sampling factor 1..30 */
    
    // typedef int pixel[4]; /* BGRc */
    private var network : Array<Dynamic>;  /* the network itself - [netsize][4] */  
    private var netindex : Array<Dynamic> = new Array<Dynamic>();
    
    /* for network lookup - really 256 */
    private var bias : Array<Dynamic> = new Array<Dynamic>();
    
    /* bias and freq arrays for learning */
    private var freq : Array<Dynamic> = new Array<Dynamic>();
    private var radpower : Array<Dynamic> = new Array<Dynamic>();
    
    public function new(thepic : ByteArray, len : Int, sample : Int)
    {
        
        var i : Int = 0;
        var p : Array<Dynamic>;
        
        thepicture = thepic;
        lengthcount = len;
        samplefac = sample;
        
        network = new Array<Dynamic>(netsize);
        
        for (i in 0...netsize){
            
            network[i] = new Array<Dynamic>(4);
            p = network[i];
            p[0] = p[1] = p[2] = (i << (netbiasshift + 8)) / netsize;
            freq[i] = intbias / netsize;  /* 1/netsize */  
            bias[i] = 0;
        }
    }
    
    private function colorMap() : ByteArray
    {
        
        var map : ByteArray = new ByteArray();
        var index : Array<Dynamic> = new Array<Dynamic>(netsize);
        for (i in 0...netsize){index[network[i][3]] = i;
        }
        var k : Int = 0;
        for (l in 0...netsize){
            var j : Int = index[l];
            map[k++] = (network[j][0]);
            map[k++] = (network[j][1]);
            map[k++] = (network[j][2]);
        }
        return map;
    }
    
    /*
	   * Insertion sort of network and building of netindex[0..255] (to do after
	   * unbias)
	   * -------------------------------------------------------------------------------
	   */
    
    private function inxbuild() : Void
    {
        
        var i : Int = 0;
        var j : Int = 0;
        var smallpos : Int = 0;
        var smallval : Int = 0;
        var p : Array<Dynamic>;
        var q : Array<Dynamic>;
        var previouscol : Int = 0;
        var startpos : Int = 0;
        
        previouscol = 0;
        startpos = 0;
        for (i in 0...netsize){
            
            p = network[i];
            smallpos = i;
            smallval = p[1];  /* index on g */  
            /* find smallest in i..netsize-1 */
            for (j in i + 1...netsize){
                q = network[j];
                if (q[1] < smallval) 
                {  /* index on g */  
                    
                    smallpos = j;
                    smallval = q[1];
                }
            }
            
            q = network[smallpos];
            /* swap p (i) and q (smallpos) entries */
            
            if (i != smallpos) 
            {
                
                j = q[0];
                q[0] = p[0];
                p[0] = j;
                j = q[1];
                q[1] = p[1];
                p[1] = j;
                j = q[2];
                q[2] = p[2];
                p[2] = j;
                j = q[3];
                q[3] = p[3];
                p[3] = j;
            }  /* smallval entry is now in position i */  
            
            
            
            
            if (smallval != previouscol) 
            
            {
                
                netindex[previouscol] = (startpos + i) >> 1;
                
                for (j in previouscol + 1...smallval){netindex[j] = i;
                }
                
                previouscol = smallval;
                startpos = i;
            }
        }
        
        netindex[previouscol] = (startpos + maxnetpos) >> 1;
        for (j in previouscol + 1...256){netindex[j] = maxnetpos;
        }
    }
    
    /*
	   * Main Learning Loop ------------------
	   */
    
    private function learn() : Void
    
    {
        
        var i : Int = 0;
        var j : Int = 0;
        var b : Int = 0;
        var g : Int = 0;
        var r : Int = 0;
        var radius : Int = 0;
        var rad : Int = 0;
        var alpha : Int = 0;
        var step : Int = 0;
        var delta : Int = 0;
        var samplepixels : Int = 0;
        var p : ByteArray;
        var pix : Int = 0;
        var lim : Int = 0;
        
        if (lengthcount < minpicturebytes)             samplefac = 1;
        
        alphadec = 30 + ((samplefac - 1) / 3);
        p = thepicture;
        pix = 0;
        lim = lengthcount;
        samplepixels = lengthcount / (3 * samplefac);
        delta = samplepixels / ncycles;
        alpha = initalpha;
        radius = initradius;
        
        rad = radius >> radiusbiasshift;
        if (rad <= 1)             rad = 0;
        
        for (i in 0...rad){radpower[i] = alpha * (((rad * rad - i * i) * radbias) / (rad * rad));
        }
        
        
        if (lengthcount < minpicturebytes)             step = 3
        else if ((lengthcount % prime1) != 0)             step = 3 * prime1
        else 
        
        {
            
            if ((lengthcount % prime2) != 0)                 step = 3 * prime2
            else 
            
            {
                
                if ((lengthcount % prime3) != 0)                     step = 3 * prime3
                else step = 3 * prime4;
            }
        }
        
        i = 0;
        
        while (i < samplepixels)
        
        {
            
            b = (p[pix + 0] & 0xff) << netbiasshift;
            g = (p[pix + 1] & 0xff) << netbiasshift;
            r = (p[pix + 2] & 0xff) << netbiasshift;
            j = contest(b, g, r);
            
            altersingle(alpha, j, b, g, r);
            
            if (rad != 0)                 alterneigh(rad, j, b, g, r)  /* alter neighbours */  ;
            
            pix += step;
            
            if (pix >= lim)                 pix -= lengthcount;
            
            i++;
            
            if (delta == 0)                 delta = 1;
            
            if (i % delta == 0) 
            
            {
                
                alpha -= alpha / alphadec;
                radius -= radius / radiusdec;
                rad = radius >> radiusbiasshift;
                
                if (rad <= 1)                     rad = 0;
                
                for (j in 0...rad){radpower[j] = alpha * (((rad * rad - j * j) * radbias) / (rad * rad));
                }
            }
        }
    }
    
    /*
	   ** Search for BGR values 0..255 (after net is unbiased) and return colour
	   * index
	   * ----------------------------------------------------------------------------
	   */
    
    public function map(b : Int, g : Int, r : Int) : Int
    
    {
        
        var i : Int = 0;
        var j : Int = 0;
        var dist : Int = 0;
        var a : Int = 0;
        var bestd : Int = 0;
        var p : Array<Dynamic>;
        var best : Int = 0;
        
        bestd = 1000;  /* biggest possible dist is 256*3 */  
        best = -1;
        i = netindex[g];  /* index on g */  
        j = i - 1;  /* start at netindex[g] and work outwards */  
        
        while ((i < netsize) || (j >= 0))
        
        {
            
            if (i < netsize) 
            
            {
                
                p = network[i];
                
                dist = p[1] - g;  /* inx key */  
                
                if (dist >= bestd)                     i = netsize
                /* stop iter */
                else 
                
                {
                    
                    i++;
                    
                    if (dist < 0)                         dist = -dist;
                    
                    a = p[0] - b;
                    
                    if (a < 0)                         a = -a;
                    
                    dist += a;
                    
                    if (dist < bestd) 
                    
                    {
                        
                        a = p[2] - r;
                        
                        if (a < 0)                             a = -a;
                        
                        dist += a;
                        
                        if (dist < bestd) 
                        
                        {
                            
                            bestd = dist;
                            best = p[3];
                        }
                    }
                }
            }
            
            if (j >= 0) 
            {
                
                p = network[j];
                
                dist = g - p[1];  /* inx key - reverse dif */  
                
                if (dist >= bestd)                     j = -1
                /* stop iter */
                else 
                {
                    
                    j--;
                    if (dist < 0)                         dist = -dist;
                    a = p[0] - b;
                    if (a < 0)                         a = -a;
                    dist += a;
                    
                    if (dist < bestd) 
                    
                    {
                        
                        a = p[2] - r;
                        if (a < 0)                             a = -a;
                        dist += a;
                        if (dist < bestd) 
                        {
                            bestd = dist;
                            best = p[3];
                        }
                    }
                }
            }
        }
        
        return (best);
    }
    
    public function process() : ByteArray
    {
        
        learn();
        unbiasnet();
        inxbuild();
        return colorMap();
    }
    
    /*
	  * Unbias network to give byte values 0..255 and record position i to prepare
	  * for sort
	  * -----------------------------------------------------------------------------------
	  */
    
    private function unbiasnet() : Void
    
    {
        
        var i : Int = 0;
        var j : Int = 0;
        
        for (i in 0...netsize){
            network[i][0] >>= netbiasshift;
            network[i][1] >>= netbiasshift;
            network[i][2] >>= netbiasshift;
            network[i][3] = i;
        }
    }
    
    /*
	  * Move adjacent neurons by precomputed alpha*(1-((i-j)^2/[r]^2)) in
	  * radpower[|i-j|]
	  * ---------------------------------------------------------------------------------
	  */
    
    private function alterneigh(rad : Int, i : Int, b : Int, g : Int, r : Int) : Void
    
    {
        
        var j : Int = 0;
        var k : Int = 0;
        var lo : Int = 0;
        var hi : Int = 0;
        var a : Int = 0;
        var m : Int = 0;
        
        var p : Array<Dynamic>;
        
        lo = i - rad;
        if (lo < -1)             lo = -1;
        
        hi = i + rad;
        
        if (hi > netsize)             hi = netsize;
        
        j = i + 1;
        k = i - 1;
        m = 1;
        
        while ((j < hi) || (k > lo))
        
        {
            
            a = radpower[m++];
            
            if (j < hi) 
            
            {
                
                p = network[j++];
                
                try{
                    
                    p[0] -= (a * (p[0] - b)) / alpharadbias;
                    p[1] -= (a * (p[1] - g)) / alpharadbias;
                    p[2] -= (a * (p[2] - r)) / alpharadbias;
                }                catch (e : Error){ }  // prevents 1.3 miscompilation  ;
            }
            
            if (k > lo) 
            
            {
                
                p = network[k--];
                
                try
                {
                    
                    p[0] -= (a * (p[0] - b)) / alpharadbias;
                    p[1] -= (a * (p[1] - g)) / alpharadbias;
                    p[2] -= (a * (p[2] - r)) / alpharadbias;
                }                catch (e : Error){ };
            }
        }
    }
    
    /*
	  * Move neuron i towards biased (b,g,r) by factor alpha
	  * ----------------------------------------------------
	  */
    
    private function altersingle(alpha : Int, i : Int, b : Int, g : Int, r : Int) : Void
    {
        
        /* alter hit neuron */
        var n : Array<Dynamic> = network[i];
        n[0] -= (alpha * (n[0] - b)) / initalpha;
        n[1] -= (alpha * (n[1] - g)) / initalpha;
        n[2] -= (alpha * (n[2] - r)) / initalpha;
    }
    
    /*
	  * Search for biased BGR values ----------------------------
	  */
    
    private function contest(b : Int, g : Int, r : Int) : Int
    {
        
        /* finds closest neuron (min dist) and updates freq */
        /* finds best neuron (min dist-bias) and returns position */
        /* for frequently chosen neurons, freq[i] is high and bias[i] is negative */
        /* bias[i] = gamma*((1/netsize)-freq[i]) */
        
        var i : Int = 0;
        var dist : Int = 0;
        var a : Int = 0;
        var biasdist : Int = 0;
        var betafreq : Int = 0;
        var bestpos : Int = 0;
        var bestbiaspos : Int = 0;
        var bestd : Int = 0;
        var bestbiasd : Int = 0;
        var n : Array<Dynamic>;
        
        bestd = ~(1 << 31);
        bestbiasd = bestd;
        bestpos = -1;
        bestbiaspos = bestpos;
        
        for (i in 0...netsize){
            
            n = network[i];
            dist = n[0] - b;
            
            if (dist < 0)                 dist = -dist;
            
            a = n[1] - g;
            
            if (a < 0)                 a = -a;
            
            dist += a;
            
            a = n[2] - r;
            
            if (a < 0)                 a = -a;
            
            dist += a;
            
            if (dist < bestd) 
            
            {
                
                bestd = dist;
                bestpos = i;
            }
            
            biasdist = dist - ((bias[i]) >> (intbiasshift - netbiasshift));
            
            if (biasdist < bestbiasd) 
            
            {
                
                bestbiasd = biasdist;
                bestbiaspos = i;
            }
            
            betafreq = (freq[i] >> betashift);
            freq[i] -= betafreq;
            bias[i] += (betafreq << gammashift);
        }
        
        freq[bestpos] += beta;
        bias[bestpos] -= betagamma;
        return (bestbiaspos);
    }
}

