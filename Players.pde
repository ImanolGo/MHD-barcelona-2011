/* --------------------------------------------------------------------------
 * Kinect Dubstep.
 * --------------------------------------------------------------------------
 * Musical Hack created for the MHD Barcelona 2011 and using the SimpleOpenNI
 * processing library by Max Rheiner
 *
 * Website: http://wiki.musichackday.org/index.php?title=Drop%27Em_Dub
 * Source Code: https://ImanolGo@github.com/ImanolGo/MHD-barcelona-2011.git
 * --------------------------------------------------------------------------
 * prog:  Imanol Gomez / SMC master Student / MTG Barcelona/ http://mtg.upf.edu/
 * date:  17/06/2011 (dd/mm/yyyy)
 * ----------------------------------------------------------------------------
 */
 
class BassPlayer {
  
  OscP5 oscP5;
  NetAddress myRemoteLocation;
  
  int iMax,iMin;
  int iLeft,iRight;
  int rectWidth,rectHeight;
  int iPitch,iCutOff,iCutOffPos,iCutOffPre,iLFO,iLFOPre,iLFOPos;
  int iNumNotes,iOffsetNotes;
  int[] Notes;
  
  void Setup(int w, int h)
  {
     iMax = 2*h/3 - h/8;
     iMin = 2*h/3 + h/8;
     iLeft = w/16;
     iRight = w*15/16;
     iPitch = 0;
     iCutOff =iCutOffPre = 0;
     iLFO = iLFOPre = 0;
     iLFOPos = 0;
     iCutOffPos = 0;
     iNumNotes = 10;
     iOffsetNotes = 30;
     oscP5 = new OscP5(this,12000);
     myRemoteLocation = new NetAddress("127.0.0.1",12000);
     
     Notes = new int[iNumNotes];
     int refNote = 24; 
     Notes[0] = refNote; //I
     Notes[1] = refNote + 3; //III
     Notes[2] = refNote + 5; //IV
     Notes[3] = refNote+ 7; //V
     Notes[4] = refNote + 10; //VI
     
     for (int i=5;i< iNumNotes;i++)
     {
         Notes[i] = Notes[i%5] + 12*(i/5);
     }
  }
  
  void update(PVector LeftHand, PVector RightHand)
  {
        
    if(LeftHand.x>iLeft && LeftHand.x<iRight && LeftHand.y>iMax && LeftHand.y< iMin)
    { 
         
         float fDinst = abs(iMin-iMax);
         int newCutOff  = 127 - (int) floor(127*(LeftHand.y - iMax)/fDinst);
         //print (" x = " +newCutOff);
         if (newCutOff != iCutOff)
         {
             iCutOff = newCutOff;
             OscMessage myMessage = new OscMessage("/CutOff");
             myMessage.add(iCutOff); /* add an int to the osc message */
             oscP5.send(myMessage, myRemoteLocation); 
         }   
        
         fDinst = abs(iRight-iLeft)/2;
         int newLFO  = (int) floor(127*(LeftHand.x - iLeft)/fDinst);
         if(newLFO>127)
             newLFO = 127;
         if (newLFO != iLFO)
         {
             iLFO = newLFO;
             OscMessage myMessage = new OscMessage("/LFO");
             myMessage.add(iLFO); /* add an int to the osc message */
             oscP5.send(myMessage, myRemoteLocation); 
         }   
    }
    
   else
    {
       OscMessage myMessage = new OscMessage("/Pitch");
       myMessage.add(iPitch); /* add an int to the osc message */
       myMessage.add(0); /* Velocity zero */ 
       oscP5.send(myMessage, myRemoteLocation); 
    }
     
    if(RigthHand.y>iMax && RigthHand.y< iMin && RigthHand.x>iLeft && RigthHand.x<iRight)
      {
         float fDinst = abs(iMin-iMax);
         int ind  = (int) floor((iNumNotes)*(RigthHand.y - iMax)/fDinst);
         ind = iNumNotes - ind -1;
         int newPitch =  Notes[ind];
         if (newPitch != iPitch)
         {
//             OscMessage myMessage = new OscMessage("/Pitch");
//             myMessage.add(iPitch); /* add an int to the osc message */
//             myMessage.add(0); /* Velocity zero */ 
//             oscP5.send(myMessage, myRemoteLocation); 
             iPitch = newPitch;
             OscMessage myMessage = new OscMessage("/Pitch");
             myMessage.add(iPitch); /* add an int to the osc message */
             myMessage.add(127); /* Velocity zero */ 
             oscP5.send(myMessage, myRemoteLocation); 
         }   
      }    
      
      else
      {
         OscMessage myMessage = new OscMessage("/Pitch");
         myMessage.add(iPitch); /* add an int to the osc message */
         myMessage.add(0); /* Velocity zero */ 
         oscP5.send(myMessage, myRemoteLocation); 
      }
      
      
//      if(LeftHand.y<iMax || LeftHand.y> iMin || LeftHand.x<iLeft || LeftHand.x>iRight)
//      {
//            if(RightHand.y<iMax || RightHand.y> iMin || RightHand.x<iLeft || RightHand.x>iRight)
//            {
//                 for (int i=5;i< iNumNotes;i++)
//                 {
//                     OscMessage myMessage = new OscMessage("/Pitch");
//                     myMessage.add(Notes[i]); /* add an int to the osc message */
//                     myMessage.add(0); /* Velocity zero */ 
//                     oscP5.send(myMessage, myRemoteLocation); 
//                 }
//                
//            } 
//      }
  }
  
  void display()
  {
      stroke(255,255,255);
      noFill();
      rect(iLeft,iMax, abs(iLeft-iRight),abs(iMax-iMin));
  }
  
}

class DrumPlayer {
  
  OscP5 oscP5;
  NetAddress myRemoteLocation;
  
  int iMax,iMin, iMaxSmall,iMinSmall,iMaxSmall_2,iMinSmall_2;
  int iLeft,iRight,iLeftSmall,iRightSmall,iLeftSmall_2,iRightSmall_2;
  int iPitch,iFreq, iBeatOff,iBeatVol,iQ;
  int iNumNotes,iOffsetNotes;
  int[] TriggerNotes;
  int iDelayPre;
  boolean bAllowTrigger,bAllowStop,bAllowDelay;
  int   iTriggerInd, iDelay;
  color c,c2;
  
  void Setup(int w, int h)
  {
     iMax = 2*h/3 - h/8;
     iMin = 2*h/3 + h/8;
     iLeft = w/16;
     iRight = w*15/16;
     
     iMaxSmall = 4*h/16;
     iMinSmall = 5*h/16;
     iLeftSmall = 13*w/16;
     iRightSmall = w*15/16;
     iMaxSmall_2 = 4*h/16;
     iMinSmall_2 = 5*h/16;
     iLeftSmall_2 = 9*w/16;
     iRightSmall_2 = w*11/16;
     iTriggerInd = 0;
     iPitch = 0;
     iFreq = iBeatVol = iBeatOff = iQ = 0;
     iNumNotes = 9;
     iOffsetNotes = 30;
     oscP5 = new OscP5(this,12000);
     myRemoteLocation = new NetAddress("127.0.0.1",12000);
     bAllowTrigger = bAllowStop  = bAllowDelay = true;
     c = color(255, 255, 255, 128);
     c2 = color(255, 255, 255, 128);
     iDelay = 0;
     
     TriggerNotes = new int[iNumNotes];
     for (int i=0;i< iNumNotes;i++)
     {
         TriggerNotes[i] = 48 + i;
     }
  }
  
  void update(PVector LeftHand, PVector RightHand)
  {
      
      if(RigthHand.x>iLeft && RigthHand.x<iRight && RigthHand.y>iMax && RigthHand.y< iMin)
      { 
             float fDist = abs(iRight-iLeft)/2;
             int x  = (int) floor(127*(RigthHand.x - (iLeft + abs(iRight-iLeft)/2))/fDist);
             if(x<0)
                 x = 0;
             fDist = abs(iMin-iMax);
             int y  = 127 - (int) floor(127*(RigthHand.y - iMax)/fDist);
            
             OscMessage myMessage = new OscMessage("/DrumRH");
             myMessage.add(x); /* add an int to the osc message */
             myMessage.add(y); /* add an int to the osc message */
             oscP5.send(myMessage, myRemoteLocation); 
      }
        
      if(LeftHand.y>iMax && LeftHand.y< iMin && LeftHand.x>iLeft && LeftHand.x<iRight)
          {
               float fDist = abs(iRight-iLeft)/2;
               int x  = (int) floor(127*(LeftHand.x - (iLeft + abs(iRight-iLeft)/2))/fDist);
               if(x<0)
                 x = 0;
               fDist = abs(iMin-iMax);
               int y  = 127 - (int) floor(127*(LeftHand.y - iMax)/fDist);
              
               OscMessage myMessage = new OscMessage("/DrumLH");
               myMessage.add(x); /* add an int to the osc message */
               myMessage.add(y); /* add an int to the osc message */
               oscP5.send(myMessage, myRemoteLocation); 
          }
          
      if(RigthHand.x>iLeftSmall && RigthHand.x<iRightSmall && RigthHand.y>iMaxSmall && RigthHand.y< iMinSmall)
      {
           
           bAllowTrigger = false;
           OscMessage myMessage = new OscMessage("/Trigger");
           myMessage.add(TriggerNotes[iTriggerInd]); /* add an int to the osc message */
           oscP5.send(myMessage, myRemoteLocation);
          
           iTriggerInd = iTriggerInd + 1;
           if (iTriggerInd>=iNumNotes-1)
               iTriggerInd = 0;     
           
           c = color(204, 153, 0, 128);
      } 
      
      else if(LeftHand.x>iLeftSmall && LeftHand.x<iRightSmall && LeftHand.y>iMaxSmall && LeftHand.y< iMinSmall)
      {
           bAllowTrigger = false;
           OscMessage myMessage = new OscMessage("/Trigger");
           myMessage.add(TriggerNotes[iTriggerInd]); /* add an int to the osc message */
           oscP5.send(myMessage, myRemoteLocation);
          
           iTriggerInd = iTriggerInd + 1;
           if (iTriggerInd>=iNumNotes-1)
               iTriggerInd = 0;     
           
           c = color(204, 153, 0, 128);
      } 
      else
      {
           bAllowTrigger = true;
           c = color(255, 255, 255, 128);
      }
      
      if(RigthHand.x>iLeftSmall_2 && RigthHand.x<iRightSmall_2 && RigthHand.y>iMaxSmall_2 && RigthHand.y< iMinSmall_2 ||
         LeftHand.x>iLeftSmall_2 && LeftHand.x<iRightSmall_2 && LeftHand.y>iMaxSmall_2 && LeftHand.y< iMinSmall_2  )
      {   
          if(bAllowDelay)
          {
              iDelay = iDelay + 64;
              if(iDelay>65)
                 iDelay = 0;
              print (iDelay + ", ");
              OscMessage myMessage = new OscMessage("/Delay");
              myMessage.add(iDelay); /* add an int to the osc message */
              oscP5.send(myMessage, myRemoteLocation);
              bAllowDelay = false;     
          }
          
          c2 = color(204, 153, 0, 128);
     
      } 
      else
      {
           bAllowDelay = true;
           c2 = color(255, 255, 255, 128);
      }
      
      if(LeftHand.y<iMax || LeftHand.y> iMin || LeftHand.x<iLeft || LeftHand.x>iRight)
      {
            if(RightHand.y<iMax || RightHand.y> iMin || RightHand.x<iLeft || RightHand.x>iRight)
            {
                   OscMessage myMessage = new OscMessage("/Trigger");
                   myMessage.add(TriggerNotes[iNumNotes-1]); /* add an int to the osc message */
                   oscP5.send(myMessage, myRemoteLocation);
                   bAllowStop = false;  
            } 
      } 
     
  }
  
  void display()
  {
      stroke(255,255,255);
      noFill();
      rect(iLeft,iMax, abs(iLeft-iRight),abs(iMax-iMin));
      fill(c);
      rect(iLeftSmall,iMaxSmall, abs(iLeftSmall-iRightSmall),abs(iMaxSmall-iMinSmall));
      fill(c2);
      rect(iLeftSmall_2,iMaxSmall_2, abs(iLeftSmall_2-iRightSmall_2),abs(iMaxSmall_2-iMinSmall_2));
      
  }
  
}

