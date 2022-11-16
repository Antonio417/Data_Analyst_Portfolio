import numpy as np

# In Regression we want to predict a continuous value
# While in Classification we want to predict a discrete value like a class label 0 to 10
class LinearRegression:
    # Steps:
    # 1. Predict Values using a linear function y = wx + b, initialize weights and bias as zero 
    # 2. Find the weights and bias using a cost function which in linear regression we use MSE
    # MSE = (1/number of sample) * sum( (actual value(y) - predicted value(yHat))^2 ) 
    # 3. We want the MSE function to be as low as possible, so we find the minimum of our MSE function using derivative
    # 4. Use gradient descent to get the minimum where
    # weights(n+1) = weights(n) - learning rate * derivative of MSE with respect to weights(df/dw)
    # bias(n+1) = bias(n) - learning rate * derivative of MSE with respect to bias(df/db)
    # 5. After getting the minimum, then y_predicted = wX + b with the updated weights and bias 

    def __init__(self, learning_rate=0.001, n_iters=1000):
        self.lr = learning_rate # the smaller it is the better but it will take more time to finish training
        self.n_iters = n_iters 
        self.weights = None # weights is the trainable parameter
        self.bias = None

    def fit(self, X, y): 
        # takes the training samples and labels 
        # this part involves the training step and gradient descent to fi the minima of our loss functionf
        n_samples, n_features = X.shape # to get the number of samples

        # init parameters
        self.weights = np.zeros(n_features) # To initialize every weights to zero
        self.bias = 0 # To initialize the bias to zero

        # gradient descent
        for _ in range(self.n_iters):
            y_predicted = np.dot(X, self.weights) + self.bias # this is equal to y = wX + b where w is weights and b is bias
            # compute gradients
            dw = (1 / n_samples) * np.dot(X.T, (y_predicted - y)) # Derivative of MSE loss function with respect to the weight
            db = (1 / n_samples) * np.sum(y_predicted - y) # Derivative of MSE loss function with respect to the bias 

            # update parameters
            self.weights -= self.lr * dw 
            self.bias -= self.lr * db

    def predict(self, X):
        y_predicted = np.dot(X, self.weights) + self.bias
        return y_predicted



