# Linear Regression solve a continuous regression problems and output is discrete
# Logistic Regression solve a classification problem and output is continuous
# The purpose of Linear Regression is to find the best-fitted line while Logistic 
# Regression is fitting the line values to the sigmoid curve
# Loss Function for Linear Regression is the Mean-Squared-Error(MSE)
# Loss Function for Logistic Regression is the Cross Entropy

import numpy as np

class LogisticRegression:

    def __init__(self, learning_rate=0.001, n_iters=1000):
        self.lr = learning_rate
        self.n_iters = n_iters
        self.weights = None
        self.bias = None
    
    def _sigmoid(self, x):
        return 1 / (1 + np.exp(-x))

    def fit(self, X, y):
        n_samples, n_features = X.shape

        # init parameters
        # initialize weights and bias as 0
        self.weights = np.zeros(n_features)
        self.bias = 0

        # gradient descent
        for _ in range(self.n_iters):
            # approximate y = wX + b
            linear_model = np.dot(X, self.weights) + self.bias
            # apply sigmoid function
            y_predicted = self._sigmoid(linear_model) # This the approximation of y
            # compute gradients using the derivative of our loss function with respect to weights and bias
            dw = (1 / n_samples) * np.dot(X.T, (y_predicted - y))
            db = (1 / n_samples) * np.sum(y_predicted - y)
            self.weights -= self.lr * dw
            self.bias -= self.lr * db
    
    def predict(self, X):
        linear_model = np.dot(X, self.weights) + self.bias
        y_predicted = self._sigmoid(linear_model)
        y_predicted_cls = [1 if i > 0.5 else 0 for i in y_predicted]
        return y_predicted_cls

    