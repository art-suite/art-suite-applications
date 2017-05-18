### FluxChallenge

Read the rules here: [github:FluxChallenge](https://github.com/staltz/flux-challenge)

### Deviations

This demo deviates from the strict rules of the challenge in order to fit within the Art-Suite Demos:

* 100% ArtSuite (the challenge requires JavaScript and DOM)
* Faked remote server
	* No dependency on a local server.
	* This way it can run on the web.
	* 100% logically identical to the original problem.
	* Faked:
		* web-socket is faked with a random timeout updating ObiWan's location
		* DarkJedi requests are faked with another random timeout then update per request.
		* Uncompleted DarkJedi requests are fake-aborted.

### Demo Notes

This is my first pass. What I like is it's pretty lean and it leverages ArtFlux nicely. What I don't like is the View sends data back to the Model, breaking one-way data-flow.

### Plans

I think I can implement my cascading subscriptions 100% in-model almost as elegantly. Overall, that should dramatically increase the system's elegance.

Further, once done, only the Models are special. The rest is POR - plain-old-react. I love acronyms.

I think from there I might be able to hook those models up to a 100% Facebook-React UX and submit to the challenge.