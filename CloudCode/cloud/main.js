
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


//Increment votes received for a specific user
Parse.Cloud.define("incrementUserVote", function(request, response) {
                   query = new Parse.Query("User");
                   query.equalTo("username", request.params.username);
                   
                   query.find({
                              success: function(results) {
                                for (var i = 0; i < results.length; ++i) {
                                    results[i].increment("receivedBangs", 1);
                                    results[i].save(null, {useMasterKey : true});
                                }
                              
                                response.success("successful increment: ");
                              },
                              error: function() {
                                response.error("failed to increment");
                              }
                              });
                   });

//Increment number of followers for a specific user
Parse.Cloud.define("incrementNumberOfFollowers", function(request, response) {
                   query = new Parse.Query("User");
                   query.equalTo("username", request.params.username);
                   
                   query.find({
                              success: function(results) {
                              for (var i = 0; i < results.length; ++i) {
                                results[i].increment("numberOfFollowers", 1);
                                results[i].save(null, {useMasterKey : true});
                              }
                              
                                response.success("sucessful; increment");
                              },
                              error: function() {
                                response.error("failed to increment");
                              }
                              });
                   });

//Decrement number of followers for a specific user
Parse.Cloud.define("decrementNumberOfFollowers", function(request, response) {
                   query = new Parse.Query("User");
                   query.equalTo("username", request.params.username);
                   
                   query.find({
                              success: function(results) {
                              for (var i = 0; i < results.length; ++i) {
                              results[i].increment("numberOfFollowers", -1);
                              results[i].save(null, {useMasterKey : true});
                              }
                              
                              response.success("sucessful; increment");
                              },
                              error: function() {
                              response.error("failed to increment");
                              }
                              });
                   });

//Calculate voteRate before a save
Parse.Cloud.beforeSave("BangTopic", function(request, response) {
                      
                      var today = new Date();
                      var createdDate = request.object.get('createdAt');
                       
                       if (createdDate === undefined || createdDate === null) {
                            createdDate = new Date();
                       }
                       
                       
                      var totalVotes = request.object.get('numberOfVotes');
                       console.log("total votes " + totalVotes);
                       
                      //Get one day in milliseconds
                      var oneHour = 1000 * 60 * 60;
                      
                      //Convert dates to milliseconds
                      var todayMs = today.getTime();
                      var createdMs = createdDate.getTime();
                       console.log("today Ms:" + todayMs);
                       console.log("createdMs:" + createdMs);

                      
                      //Calculate differences
                      var differenceMs = todayMs - createdMs;
                       console.log("difference in ms:" + differenceMs);

                      
                      //Convert back to days
                      var difference = Math.round(differenceMs/oneHour);
                       console.log("difference in hours:" + difference);

                      
                      //Calculate vote rate
                       if (difference < 1) {
                            var voteRate = 0;
                       } else {
                            var voteRate = totalVotes / difference;
                       };
                      
                       
                       console.log("vote rate:" + voteRate);
                      
                      
                       if (voteRate >= 0) {
                          request.object.set('voteRate', voteRate);
                          console.log("success");
                       response.success();
                       } else {
                          console.log("failed");
                          reponse.error();
                       }
                       
                       
                     
                      
                      
                      });





Parse.Cloud.job("bangRateRecalculation", function(request, status)
                {
                
                var query = new Parse.Query("BangTopic");
                //query.equalTo("isDeleted", "false");
                
                    query.find({
                               success: function(results) {
                               alert("Successfully retrieved " + results.length + " Bangs");
                                    // save bangTopic to trigger recalc
                                   for (var i = 0; i < results.length; i++) {
                                        var object = results[i];
                                        object.save();
                                   }
                               },
                               error: function(error) {
                                    alert("Error: " + error.code + " " + error.message);
                               }
                    });
                });
                
                
                
//                query.each(function(bangTopic) {
//                           bangTopic.save();
//                           }).then(function(){
//                                status.success("Updates completed successfully.");
//                           }, function(error) {
//                                status.error("Something went wrong");
//                           });
//                
//                
//                });

                   
                   
                   
                   

