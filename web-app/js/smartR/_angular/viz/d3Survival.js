//# sourceURL=d3Survival.js

'use strict';

window.smartRApp.directive('survivalPlot', [
	'smartRUtils', 
	'rServeService', 
	function(smartRUtils, rServeService) {
		
		return {
			restrict: 'E',
			scope: {
				data: '=',
				width: '@',
				height: '@'
			},
			link: function (scope, element) {
				/**
				 * Watch data model (which is only changed by ajax calls when we want to (re)draw everything)
				 */
				scope.$watch('data', function() {
					$(element[0]).empty();
					if (! $.isEmptyObject(scope.data)) {
						smartRUtils.prepareWindowSize(scope.width, scope.height);
						createSurvivalViz(scope, element[0]);
					}
				});
			}
		};
		
		function createSurvivalViz(scope, root) {
			
			/* Global Settings */
			var scopeWidth = parseInt(scope.width); // 1100
			var scopeHeight = parseInt(scope.height); // 700
			var margin = {
				top: 20,
				right: 20,
				bottom: 20,
				left: 20
			};
			var width = scopeWidth - 2*margin.left - 2*margin.right; // 1020
			var height = scopeHeight - 2*margin.top - 2*margin.bottom; // 620
			
			/* Design */
			var colors = [
				'red',
				'green',
				'blue',
				'orange',
				'black',
				'gray',
				'yellow',
				'purple'
			];
			
			/* Data */
			var max = 0;
			var min= 10000000000000000000;
			var givenData = scope.data.survival_data;
			
			/* Visualization Settings */
			var xLabel = smartRUtils.shortenConcept(new String(scope.data.x_label));
			var legendLabels = scope.data.legend_labels;
			var timeOut = scope.data.time_out;
			
			/* Computed Data progression, survival, prob, censored  */
			for(var a=0; a<givenData.length; a++){
				for (var b=0; b<givenData[a].length; b++){
					var reed = givenData[a][b];
					var brad = (b>0) ? givenData[a][b-1].n - reed.d : reed.n;
					reed.progression = reed.d/reed.n;
					reed.survival = 1 - reed.progression;
					reed.prob = (b == 0) ? reed.survival : givenData[a][b-1].prob*reed.survival;
					max = (max < reed.t) ? reed.t : max;
					min = (min < reed.t) ? min : reed.t;
					reed.censored = (reed.n < brad) ? true : false;
				}
			}
			
			/* Begin d3.js */
				
				// Define domains for the axes
				var xDomain = [min, max];
				var yDomain = [1, 0];
				
				//Scalar functions
				var x = d3.scale.linear()
					.range([0, width])
					.domain(xDomain).nice();
				var y = d3.scale.linear()
					.range([0, height])
					.domain(yDomain);
				
				// This chart will display years as integers, and populations with thousands separators
				var formatY = d3.format(",");
				var formatX = d3.format(".");
				
				//Define axes
				var xAxis = d3.svg.axis()
					.scale(x)
					.innerTickSize(-height)
					.outerTickSize(2)
					.tickPadding(6)
					.tickFormat(formatX)
					.orient("bottom");
				
				var yAxis = d3.svg.axis()
					.scale(y)
					.innerTickSize(-width)
					.outerTickSize(2)
					.tickPadding(6)
					.orient('left');
				
				//This is the accessor function
				var lineFunction = d3.svg.line()
					.x(function(d) { return x(d.t); })
					.y(function(d) { return y(d.prob); })
					.interpolate("step-before");
				
				/* Drawing starts here */
				
					//Draw the svg container
					var kaplan = d3.select(root).append('svg')
							.attr('width', scopeWidth)
							.attr('height', scopeHeight)
							.append('g')
							.attr('transform', 'translate(' + 50 + ',' + 0 + ')')
					
					//Draw the x-axis
					var theXAxis = kaplan.append("g")
						.attr("class", "x axis")
						.attr('transform', 'translate(' + 0 + ',' + (height + margin.bottom) + ')')
						.call(xAxis);
						
					// Add the text label for the x axis
					var theXLabel = kaplan.append("text")
						.attr('class', 'axisLabels')
						.attr("transform", "translate(" + (width / 2) + " ," + (scopeHeight-margin.bottom) + ")")
						.text(xLabel + " [" + timeOut + "]");
					
					//Draw the y-axis
					var theYAxis = kaplan.append("g")
						.attr("class", "y axis")
						.attr('transform', 'translate(' + 0 + ',' + margin.top + ')')
						.call(yAxis);
						
					// Add the text label for the Y axis
					var theYLabel = kaplan.append("text")
						.attr('class', 'axisLabels')
						.attr("transform", "rotate(-90)")
						.attr("y", -50)
						.attr("x",0 - (height / 2))
						.attr("dy", "1em")
						.text("Fraction of Patients");
					
					// Draw the tooltip-container
					var hoverDiv = d3.select(root)
								.append("div")
								.attr("class", "tooltip")
								.style("position", "absolute")
								.style("opacity", 0);
					
					// Draw the lines
					for(var a=0; a < givenData.length; a++){
						var line = kaplan.append("path")
							.attr("d", lineFunction(givenData[a]))
							.attr("stroke", colors[a])
							.attr("stroke-width", 3)
							.attr("fill", "none")
							.attr("opacity", 0.7)
							.attr('transform', 'translate(' + 0 + ',' + margin.top + ')')
							.on('mouseover', function () {
								//on mouseover of each line, give it a nice thick stroke
								d3.select(this).style("stroke-width", '10px');
								hoverDiv.html("<b>" + timeOut + " survived:</b> " + d3.format(".1f")(x.invert(d3.mouse(this)[0])) + "<br/><b>probability of survival:</b> " + d3.format(".2%")(y.invert(d3.mouse(this)[1])));
								hoverDiv.transition()
										.duration(200)
										.style("opacity", 0.8)
										.style("left", (d3.mouse(this)[0]+90) + "px")
										.style("top", (d3.mouse(this)[1]+310) + "px");
							})
							.on("mousemove", function() {
								hoverDiv.html("<b>" + timeOut + " survived:</b> " + d3.format(".1f")(x.invert(d3.mouse(this)[0])) + "<br/><b>probability of survival:</b> " + d3.format(".2%")(y.invert(d3.mouse(this)[1])));
								hoverDiv.style("left", (d3.mouse(this)[0]+90) + "px")
										.style("top", (d3.mouse(this)[1]+310) + "px");
							})
							.on('mouseout', function () {
								d3.select(this).style("stroke-width", "3px");
								hoverDiv.transition()
										.duration(500)
										.style("opacity", 0);
							});
					}
				
				/* Drawing ends here */
				
			/* End d3.js */
			
		}
	
    }
	
]);
