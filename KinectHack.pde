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

import SimpleOpenNI.*;
import oscP5.*;
import netP5.*;

SimpleOpenNI  context;
IntVector  userList;
PVector jointPos,RigthHand,LeftHand;
XnVector3D jointPos3D;
BassPlayer bassPlayer1;
DrumPlayer drumPlayer1;

int UserBass,UserDrums,iWidth,iHeight,numPlayers;

void setup()
{
  
  UserBass = UserDrums = -1;
  numPlayers = 0;
  jointPos = new PVector();
  context = new SimpleOpenNI(this);
  userList = new IntVector();
  jointPos3D = new XnVector3D();
  RigthHand = new PVector();
  LeftHand = new PVector();
  bassPlayer1 = new BassPlayer();
  drumPlayer1 = new DrumPlayer();
 
  // enable depthMap generation 
  //context.enableRGB();
  context.enableDepth();
  
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
 
  background(200,0,0);

  iWidth = context.depthWidth();
  iHeight = context.depthHeight(); 
  //iWidth = screen.width;
  //iHeight = screen.height;

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  size(iWidth, iHeight); 
  
  bassPlayer1.Setup(iWidth,iHeight);
  drumPlayer1.Setup(iWidth,iHeight);
  context.setMirror(true);
}

void draw()
{
  // update the cam
  context.update();
  //updateMIDI();
  
  // draw depthImageMap
   image(context.depthImage(),0,0,iWidth,iHeight);
   if(context.isTrackingSkeleton(UserBass)){
        //print("UserBass = " + UserBass) ;
        drawHands(UserBass);
        bassPlayer1.display();
        context.getJointPositionSkeleton(UserBass,SimpleOpenNI.SKEL_RIGHT_HAND,jointPos);
        context.convertRealWorldToProjective(jointPos,RigthHand);
        context.getJointPositionSkeleton(UserBass,SimpleOpenNI.SKEL_LEFT_HAND,jointPos);
        context.convertRealWorldToProjective(jointPos,LeftHand);
        bassPlayer1.update(LeftHand,RigthHand);
   }
       
   if(context.isTrackingSkeleton(UserDrums)){
        //print("UserDrums = " + UserDrums) ;
        drawHands(UserDrums);
        //drawSkeleton(UserDrums);
        drumPlayer1.display();
        context.getJointPositionSkeleton(UserDrums,SimpleOpenNI.SKEL_RIGHT_HAND,jointPos);
        context.convertRealWorldToProjective(jointPos,RigthHand);
        context.getJointPositionSkeleton(UserDrums,SimpleOpenNI.SKEL_LEFT_HAND,jointPos);
        context.convertRealWorldToProjective(jointPos,LeftHand);
        drumPlayer1.update(LeftHand,RigthHand);
   }
}

void drawHands(int userId)
{
  // Dark red
   // float fScaleWidth = iWidth/context.depthWidth();
   // float fScaleHeight =  iHeight/context.depthHeight();
    fill(127,0,0);
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,jointPos);
    context.convertRealWorldToProjective(jointPos,RigthHand);
    ellipse(RigthHand.x,RigthHand.y,16,16);
    fill(0,0,127);
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,jointPos);
    context.convertRealWorldToProjective(jointPos,LeftHand);
    ellipse(LeftHand.x,LeftHand.y,16,16);  
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  context.startPoseDetection("Psi",userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
    if(UserDrums==-1)
         UserDrums = userId;
    else if ((UserBass==-1))
         UserBass = userId;  
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
  if(UserBass==userId)
         UserBass = -1;
  if ((userId==UserDrums))
         UserDrums = -1;  
}

