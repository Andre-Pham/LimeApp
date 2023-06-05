# Takeaways

* It's really bad at detecting hooked fingers
* You can't have the hand too close to the camera for training data (and for recognition)
* Don't try to trick it with the background - if you're detecting a closed fist, don't put an almost-closed fist as part of the background training
* Be more generic - one finger out, two finger out, etc. Not two finger point, peace, etc, that's too hard for the model to detect
* Include more rotations in the dataset, it seems to struggle with that

Some things like c-shape may not be best to be detected by the model. The model is good at detecting the position of fingers, but not always the hand posture. I can write my own algorithms for detecting certain finger positions. For instance, to check if a finger is in the "closed" position, I can average out the knuckle positions, and draw a line between the hand base and the averaged knuckle, then draw two orthogonal lines through the two points, and if the joints of a finger is between that band it's closed. Other techniques can be used for detecting hooked fingers and straight fingers.