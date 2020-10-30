### FluxChallenge

> It's my personal belief that *Flux does not provide an elegant way of coordinating multiple async data sources*. - Staltz

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
		* Incompleted DarkJedi requests are fake-aborted.

### Demo Notes

I think I've succeeded in making the near-essential solution to the challenge:

1. The awkward paging system is fully handled in the 50-line Paginator model
2. Um. That's it? The Component half is clean and elegant. The other models are trivial.

### Challenge Notes

This is an odd challenge. The goal of the challenge is to test "multiple, coordinated, async data-sources," but I'm not sure the challenge does that. The two async data-sources (ObiWan and Jedi-loading) only intersect in the View. I don't think it makes sense to manage their intersection in the Models. Why? The only results of the interaction between the two are view-properties: a) highlight a slot in red and b) disable the buttons. The Paginator model could subscribe to ObiWan's location easily, but that would actually be a bad design choice. It would no longer just be a "Paginator." It violates the single-responsibility principle.

### The Awkward Pagination System

The only challenge is the pagination system, which is unlike anything I've ever encountered in the real world.

* No pagination system loads only one item at a time. Instead, they all load at least one screen-full at a time. Thus there is only, at most, two request-results visible at the same time.
* Even stranger is the "page-up" / "page-down" by 2 lines, and the not-quite-fully-defined constraints on when you are allowed to page-up or page-down. Why not the obvious-right answer: if the first slot has a master, you can page-up - a full page worth. Page-down would obviously be the opposite.
* Why do we start 3 from the bottom of the list - an awkward position that is not allowed again except by pounding the page-down button?
