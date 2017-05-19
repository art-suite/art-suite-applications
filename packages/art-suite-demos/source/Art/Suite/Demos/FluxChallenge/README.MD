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

I think this succeeds at making the near-essential solution to the challenge.

1. The awkward paging system is fully handled in the 50-line Paginator model

### Challenge Notes

This challenge is odd. The only problem is the awkward pagination system. The ObiWan current-location stuff is all trivial.

* I don't understand the purpose of the awkward paginator. No pagination system loads only one item at a time. Instead, they all load at least on screen-full at a time. Thus there is only, at most, two request-results visible at once.
* Even stranger is the "page-up" / "page-down" by 2 lines, and the not-quite-fully-defined constrains on when you are allowed to page-up or page-down. Why not the obvious-right answer: if the first slot has a master, you can page-up - a full page worth. Page-down would obviously be the opposite.
* Why do we start 3 from the bottom of the list - an awkward position that is not allowed again except by pounding the page-down button?

### Plans

I think I can implement my cascading subscriptions 100% in-model almost as elegantly. Overall, that should dramatically increase the system's elegance.

Further, once done, only the Models are special. The rest is POR - plain-old-react. I love acronyms.

I think from there I might be able to hook those models up to a 100% Facebook-React UX and submit to the challenge.