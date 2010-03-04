/*
# Copyright (c) 2010 Alexis Jacomy <alexis.jacomy@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
*/

package com.carte_du_tendre.y2010.ui{
	
	import com.carte_du_tendre.y2010.data.Graph;
	import com.carte_du_tendre.y2010.data.Node;
	import com.carte_du_tendre.y2010.display.DisplayNode;
	import com.dncompute.graphics.ArrowStyle;
	import com.dncompute.graphics.GraphicsUtil;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class DisplayMainElement extends Sprite{
		
		public static const EDGES_SCALE:Number = 100;
		
		private var _currentDisplayedNodes:Vector.<DisplayNode>;
		private var _currentSelectedDisplayNode:DisplayNode;
		private var _currentSelectedNode:Node;
		private var _graph:Graph;
		
		private var _randomAngleDelay:Number;
		private var _edgesContainer:Sprite;
		private var _nodesContainer:Sprite;
		private var _labelsContainer:Sprite;
		private var _nodesHitAreaContainer:Sprite;
		
		public function DisplayMainElement(newStage:Stage,newGraph:Graph){
			newStage.addChild(this);
			_graph = newGraph;
			_randomAngleDelay = Math.random();
			
			_edgesContainer = new Sprite();
			_nodesContainer = new Sprite();
			_labelsContainer = new Sprite();
			_nodesHitAreaContainer = new Sprite();
			
			_labelsContainer.alpha = 0;
			
			addChild(_edgesContainer);
			addChild(_nodesContainer);
			addChild(_labelsContainer);
			addChild(_nodesHitAreaContainer);
			
			trace("DisplayMainElement.DisplayMainElement: GUI initiated.");
			
			selectRandomNode();
			drawNodes();
		}
		
		private function drawNodes():void{
			var i:int = 0;
			
			if(_currentSelectedDisplayNode!=null){
				_labelsContainer.addChild(_currentSelectedDisplayNode.labelField);
			}
			
			_currentSelectedDisplayNode = new DisplayNode(_currentSelectedNode);
			
			_currentDisplayedNodes = new Vector.<DisplayNode>();
			_currentDisplayedNodes.push(_currentSelectedDisplayNode);
			
			//Remove from the scene every nodes:
			removeDisplayedNodes();
			
			//Clear every edges:
			_edgesContainer.graphics.clear();
			
			removeLabelFieldFromStage();
			
			//Add at the center of the screen the selected node:
			_currentSelectedDisplayNode.moveTo(stage.stageWidth/2,stage.stageHeight/2);;
			addNodeAsChild(_currentSelectedDisplayNode);
			stage.addChild(_currentSelectedDisplayNode.labelField);
			
			//Add all the neighbours:
			var l1:int = _currentSelectedNode.outNeighbours.length;
			var l2:int = _currentSelectedNode.inNeighbours.length;
			
			var nodeCursor:Node;
			var displayNode:DisplayNode;
			
			var style:ArrowStyle = new ArrowStyle();
			style.headLength = 5;
			style.headWidth = 5;
			style.shaftPosition = 0;
			style.shaftThickness = 4;
			style.edgeControlPosition = 0.5;
			style.edgeControlSize = 0.5;
			
			var temp_x0:Number;
			var temp_y0:Number;
			var temp_x1:Number;
			var temp_y1:Number;
			var temp_x2:Number;
			var temp_y2:Number;
			
			//Out neighbors:
			for(i=0;i<l1;i++){
				nodeCursor = _currentSelectedNode.outNeighbours[i];
				displayNode = new DisplayNode(nodeCursor);
				_currentDisplayedNodes.push(displayNode);
				
				temp_x0 = EDGES_SCALE*Math.cos(2*Math.PI*(i/(l1+l2)+_randomAngleDelay)) + stage.stageWidth/2;
				temp_y0 = EDGES_SCALE*Math.sin(2*Math.PI*(i/(l1+l2)+_randomAngleDelay)) + stage.stageHeight/2;
				displayNode.moveTo(stage.stageWidth/2,stage.stageHeight/2);
				addNodeAsChild(displayNode);
				displayNode.moveToSlowly(temp_x0,temp_y0);
				
				displayNode.upperCircle.addEventListener(MouseEvent.CLICK,whenClickANeighbour);
				
				//Draw the edge as an arrow:
				temp_x1 = DisplayNode.NODES_SCALE/EDGES_SCALE*stage.stageWidth/2 + (EDGES_SCALE-DisplayNode.NODES_SCALE)/EDGES_SCALE*temp_x0;
				temp_y1 = DisplayNode.NODES_SCALE/EDGES_SCALE*stage.stageHeight/2 + (EDGES_SCALE-DisplayNode.NODES_SCALE)/EDGES_SCALE*temp_y0;
				
				temp_x2 = (EDGES_SCALE-DisplayNode.NODES_SCALE)/EDGES_SCALE*stage.stageWidth/2 + DisplayNode.NODES_SCALE/EDGES_SCALE*temp_x0;
				temp_y2 = (EDGES_SCALE-DisplayNode.NODES_SCALE)/EDGES_SCALE*stage.stageHeight/2 + DisplayNode.NODES_SCALE/EDGES_SCALE*temp_y0;
				
				_edgesContainer.graphics.lineStyle(1,0xAAAAAA);
				_edgesContainer.graphics.beginFill(0xAAAAAA);
				
				GraphicsUtil.drawArrow(_edgesContainer.graphics,
					new Point(temp_x2,temp_y2),new Point(temp_x1,temp_y1),
					style
				);
				
				_edgesContainer.graphics.endFill();
			}
			
			//In neighbors:
			for(i=0;i<l2;i++){
				nodeCursor = _currentSelectedNode.inNeighbours[i];
				displayNode = new DisplayNode(nodeCursor);
				_currentDisplayedNodes.push(displayNode);
				
				temp_x0 = EDGES_SCALE*Math.cos(2*Math.PI*((l1+i)/(l1+l2)+_randomAngleDelay)) + stage.stageWidth/2;
				temp_y0 = EDGES_SCALE*Math.sin(2*Math.PI*((l1+i)/(l1+l2)+_randomAngleDelay)) + stage.stageHeight/2;
				displayNode.moveTo(stage.stageWidth/2,stage.stageHeight/2);
				addNodeAsChild(displayNode);
				displayNode.moveToSlowly(temp_x0,temp_y0);
				
				displayNode.upperCircle.addEventListener(MouseEvent.CLICK,whenClickANeighbour);
				
				//Draw the edge as an arrow:
				temp_x1 = 3/10*stage.stageWidth/2 + 7/10*temp_x0;
				temp_y1 = 3/10*stage.stageHeight/2 + 7/10*temp_y0;
				
				temp_x2 = 7/10*stage.stageWidth/2 + 3/10*temp_x0;
				temp_y2 = 7/10*stage.stageHeight/2 + 3/10*temp_y0;
				
				_edgesContainer.graphics.lineStyle(1,0xAAAAAA);
				_edgesContainer.graphics.beginFill(0xAAAAAA);
				
				GraphicsUtil.drawArrow(_edgesContainer.graphics,
					new Point(temp_x1,temp_y1),new Point(temp_x2,temp_y2),
					style
				);
				
				_edgesContainer.graphics.endFill();
			}
			
			addEventListener(Event.ENTER_FRAME,increaseAlpha);
		}
		
		private function increaseAlpha(e:Event):void{
			if(_labelsContainer.alpha<0.99||_edgesContainer.alpha<0.99){
				_labelsContainer.alpha = Math.min(1,_labelsContainer.alpha+0.1);
				_edgesContainer.alpha = Math.min(1,_edgesContainer.alpha+0.1);
			}else{
				removeEventListener(Event.ENTER_FRAME,increaseAlpha);
			}
		}
		
		private function selectRandomNode():void{
			var l:int = _graph.nodes.length;
			var index:int = Math.floor(Math.random()*l);
			_currentSelectedNode = _graph.nodes[index];
		}
		
		private function addNodeAsChild(displayNode:DisplayNode):void{
			_nodesContainer.addChild(displayNode);
			_labelsContainer.addChild(displayNode.labelField);
			_nodesHitAreaContainer.addChild(displayNode.upperCircle);
		}
		
		private function removeNodeAsChild(displayNode:DisplayNode):void{
			_nodesContainer.removeChild(displayNode);
			_labelsContainer.removeChild(displayNode.labelField);
			_nodesHitAreaContainer.removeChild(displayNode.upperCircle);
		}
		
		private function removeLabelFieldFromStage():void{
			var l:int = stage.numChildren;
			var i:int;
			
			for(i=0;i<l;i++){
				if(stage.getChildAt(l-1-i) is TextField){
					stage.removeChildAt(l-1-i);
				}
			}
		}
		
		public function whenClickANeighbour(e:MouseEvent):void{
			var l:int = _currentDisplayedNodes.length;
			var node:Node;
			var i:int;
			
			if(_currentSelectedDisplayNode!=null){
				_labelsContainer.addChild(_currentSelectedDisplayNode.labelField);
			}
			
			for(i=0;i<l;i++){
				if(_currentDisplayedNodes[i].upperCircle == e.target){
					node = _currentDisplayedNodes[i].node;
					stage.addChild(_currentDisplayedNodes[i].labelField);
					break;
				}
			}
			
			trace("DisplayMainElement.whenClickANeighbour: New selected node.");
			
			_currentSelectedNode = node;
			
			//drawNodes();
			addEventListener(Event.ENTER_FRAME,transitionFirstStep);
		}
		
		private function transitionFirstStep(e:Event):void{
			if(_edgesContainer.alpha>0.01){
				_edgesContainer.alpha -= 0.1;
			}else{
				removeEventListener(Event.ENTER_FRAME,transitionFirstStep);
				addEventListener(Event.ENTER_FRAME,transitionSecondStep);
			}
		}
		
		private function transitionSecondStep(e:Event):void{
			if(_labelsContainer.alpha>0.01){
				_labelsContainer.alpha -= 0.1;
			}else{
				removeEventListener(Event.ENTER_FRAME,transitionSecondStep);
				addEventListener(Event.ENTER_FRAME,transitionThirdStep);
			}
		}
		
		private function transitionThirdStep(e:Event):void{
			var d:Number = 0;
			var x_to:Number;
			var y_to:Number;
			var l:Number = _currentDisplayedNodes.length;
			
			for each(var displayNode:DisplayNode in _currentDisplayedNodes){
				x_to = displayNode.x*2/3 + stage.stageWidth/6;
				y_to = displayNode.y*2/3 + stage.stageHeight/6;
				
				displayNode.moveTo(x_to,y_to);
				
				d += Math.pow(x_to-stage.stageWidth/2,2) + Math.pow(y_to-stage.stageHeight/2,2);
			}
			
			if(d<l+1){
				removeEventListener(Event.ENTER_FRAME,transitionThirdStep);
				_randomAngleDelay = Math.random();
				drawNodes();
				
				trace("DisplayMainElement.transitionThirdStep: Third step over.");
			}
		}
		
		private function removeDisplayedNodes():void{
			var l:int;
			var i:int;
			
			//Remove first the nodes themselves:
			l = _nodesContainer.numChildren;
			for(i=0;i<l;i++){
				_nodesContainer.removeChildAt(l-1-i);
			}
			
			//Remove secondly the edges:
			l = _edgesContainer.numChildren;
			for(i=0;i<l;i++){
				_edgesContainer.removeChildAt(l-1-i);
			}
			
			//Remove next the labels:
			l = _labelsContainer.numChildren;
			for(i=0;i<l;i++){
				_labelsContainer.removeChildAt(l-1-i);
			}
			
			//Remove finally the hit areas:
			l = _nodesHitAreaContainer.numChildren;
			for(i=0;i<l;i++){
				_nodesHitAreaContainer.removeChildAt(l-1-i);
			}
		}
		
		public function get currentSelectedNode():Node{
			return _currentSelectedNode;
		}
		
		public function set currentSelectedNode(value:Node):void{
			_currentSelectedNode = value;
		}
		
		public function get graph():Graph{
			return _graph;
		}
		
		public function set graph(value:Graph):void{
			_graph = value;
		}
		
		public function get labelsContainer():Sprite{
			return _labelsContainer;
		}
		
		public function set labelsContainer(value:Sprite):void{
			_labelsContainer = value;
		}
		
		public function get edgesContainer():Sprite{
			return _edgesContainer;
		}
		
		public function set edgesContainer(value:Sprite):void{
			_edgesContainer = value;
		}
		
		public function get nodesContainer():Sprite{
			return _nodesContainer;
		}
		
		public function set nodesContainer(value:Sprite):void{
			_nodesContainer = value;
		}
		
		public function get currentDisplayedNodes():Vector.<DisplayNode>{
			return _currentDisplayedNodes;
		}
		
		public function set currentDisplayedNodes(value:Vector.<DisplayNode>):void{
			_currentDisplayedNodes = value;
		}
		
		public function get currentSelectedDisplayNode():DisplayNode{
			return _currentSelectedDisplayNode;
		}
		
		public function set currentSelectedDisplayNode(value:DisplayNode):void{
			_currentSelectedDisplayNode = value;
		}
		
		public function get randomAngleDelay():Number{
			return _randomAngleDelay;
		}
		
		public function set randomAngleDelay(value:Number):void{
			_randomAngleDelay = value;
		}
		
	}
}