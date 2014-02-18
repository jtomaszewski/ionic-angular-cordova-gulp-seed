
# A simple controller that fetches a list of data from a service

# "Pets" is a service returning mock data (services.js)

# A simple controller that shows a tapped item's data
angular.module("starter.controllers", []).controller("PetIndexCtrl", ($scope, PetService) ->
  $scope.pets = PetService.all()
).controller "PetDetailCtrl", ($scope, $stateParams, PetService) ->
  
  # "Pets" is a service returning mock data (services.js)
  $scope.pet = PetService.get($stateParams.petId)

