# QuadTreeTest

**A Cocos Demo Test**  --- Use Quadtrees to Detect Likely Collisions in 2D Space

**测试使用四叉树执行碰撞检测优化**

本例中测试使用80个子弹执行多对多的碰撞检测

 >参考：[JavaScript QuadTree Implementation](http://www.mikechambers.com/blog/2011/03/21/javascript-quadtree-implementation/)

-

###1.使用N^2检测碰撞
![QuadTreeTest screencut](https://github.com/HumanChan/QuadTreeTest/blob/master/ScreenCut/1.png?raw=true)

###2.使用四叉树检测碰撞
![QuadTreeTest screencut](https://github.com/HumanChan/QuadTreeTest/blob/master/ScreenCut/2.png?raw=true)

--
**优化情况不明显，可能的原因如下：**  

 1.由于子弹飞行速度较快，所以子弹所在的四叉树节点更新比较频繁。  
 
 2.更新四叉树的某个环节出问题或是还可以优化。