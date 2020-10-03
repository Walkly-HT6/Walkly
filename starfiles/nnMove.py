#from math import exp
#from random import random
#from random import seed
#import json


class NeuralNet:
    
    body = []
    
    #def __init__(self, inputsCount, n_hidden, outputsCount):
    def __init__(self, body): 
        self.body=[list(i) for i in body if type(i)==tuple]
        #try:
        #    with open('neuralBody.json', 'r') as file:  
        #        new_body = json.load(file) 
#
       #     self.body=new_body['body']
       # except:
       #     self.body=[[{'weights': [0.9560342718892494, 0.9478274870593494, 0.05655136772680869]}, {'weights': [0.08487199515892163, 0.8354988781294496, 0.7359699890685233]}, {'weights': [0.6697304014402209, 0.3081364575891442, 0.6059441656784624]}], [{'weights': [0.6068017336408379, 0.5812040171120031, 0.15838287025480557, 0.43066964029126864]}, {'weights': [0.39353182020537136, 0.7230120812374659, 0.9948195629497427, 0.9493954730932436]}]]
    


    # Forward propagate input to a network output
    def forward_propagate(self, row):
        output = row
        for layer in self.body:
            new_inputs = []
            for neuron in layer:
                activation = self.activate(neuron['weights'], row)
                neuron['output'] = self.transfer(activation)
                new_inputs.append(neuron['output'])
            output = new_inputs
        return output

    # Calculate neuron activation for an input
    # DONT TOUCH
    def activate(self, weights, inputs):
        activation = weights[-1]
        for i in range(len(weights)-1):
            activation += weights[i] * inputs[i]
        return activation

    # Transfer neuron activation
    def transfer(self, activation):
        return 1.0 / (1.0 + 2.71828182845904523536**-activation)

    
    # Calculate the derivative of an neuron output
    def transfer_derivative(self, output):
        return output * (1.0 - output)

    # Backpropagate error and store in neurons
    def backward_propagate_error(self, expected):
        for i in reversed(range(len(self.body))):
            layer = self.body[i]
            errors = []
            if i != len(self.body)-1:
                for j in range(len(layer)):
                    error = 0.0
                    for neuron in self.body[i + 1]:
                        error += (neuron['weights'][j] * neuron['delta'])
                    errors.append(error)
            else:
                for j in range(len(layer)):
                    neuron = layer[j]
                    errors.append(expected[j] - neuron['output'])
            for j in range(len(layer)):
                neuron = layer[j]
                neuron['delta'] = errors[j] * self.transfer_derivative(neuron['output'])


    # Update network weights with error
    def update_weights(self, row, learningRate):
        print(type(self.body))
        for i in range(len(self.body)):
            inputs = row[:-1]
            if i != 0:
                inputs = [neuron['output'] for neuron in self.body[i - 1]]
            for neuron in self.body[i]:
                for j in range(len(inputs)):
                    neuron['weights'][j] += learningRate * neuron['delta'] * inputs[j]
                neuron['weights'][-1] += learningRate * neuron['delta']
    def predict(self, row):
        outputs = self.forward_propagate(row)
        return outputs.index(max(outputs))

    # Train a network for a fixed number of epochs
    def train(self, train, learningRate, epochCount, outputsCount=2):
        for epoch in range(epochCount):
            sum_error = 0
            for row in train:
                outputs = self.forward_propagate(row)
                expected = [0 for i in range(outputsCount)]
                expected[row[-1]] = 1
                sum_error += sum([(expected[i]-outputs[i])**2 for i in range(len(expected))])
                self.backward_propagate_error(expected)
                self.update_weights(row, learningRate)
            print('>epoch=%d, lrate=%.3f, error=%.3f' % (epoch, learningRate, sum_error))
        #payload=json.dumps({"body":self.body})
        #with open('neuralBody.json','w') as file:
        #   file.write(payload)
 
            
            
            

dataset = [
    [2.7810836,2.550537003,0],
	[1.465489372,2.362125076,0],
	[3.396561688,4.400293529,0],
	[1.38807019,1.850220317,0],
	[3.06407232,3.005305973,0],
	[7.627531214,2.759262235,1],
	[5.332441248,2.088626775,1],
	[6.922596716,1.77106367,1],
	[8.675418651,-0.242068655,1],
	[7.673756466,3.508563011,1]
]
inputsCount = len(dataset[0]) - 1
outputsCount = len(set([row[-1] for row in dataset]))
#network = neuralNet(inputsCount, 3, outputsCount)

#network.train(dataset, 0.5, 2000, outputsCount)

