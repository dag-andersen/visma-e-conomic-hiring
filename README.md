# Recruitment assignment for Site Reliability Engineers

This task is intended for candidates applying for an SRE position at the Visma 
e-conomic Site Reliability Engineering team. This assignment is built around some of the 
technologies used in our production environment.

We're super happy that you're considering to join us at e-conomic. The 
challenge below should hope to bring a small view into the life of an SRE, 
and serve as a entrypoint for a good discussion at the technical interview.

## Introduction

e-conomic runs a broad palette of services to provide the functionality our customers need.
A part of this functionality is provided by a layer of microservices. 

These microservices are hosted in Kubernetes and have different requirements in 
terms of availability and resilience, both from the requests they serve but also
the data that some of them hold.

To verify how well a candidate fit our needs, the test is built with the 
intention for you to show off your skills and strengths in some technologies we use on a
daily basis.  

Should you feel like expanding above and beyond the scope of the test, feel free
to do so. We will enjoy discussing your reasoning for doing so.

## Objectives of the SRE team

* Improve the reliability of the system.
* Empower product teams to deliver and operate software efficiently and reliably, 
by providing tools, advice and assistance. 

## The Assignment

1. Develop a microservice.
	1. It takes HTTP GET requests with a random ID (/1, /529852, etc.), requests a 
  document from the microservice we have provided in the `dummy-pdf-or-png` 
  subdirectory of this repository, and then returns the document with correct 
  mime-type.
	1. Provides an endpoint for health monitoring.
	1. Has tests, so regressions can be identified.
	1. Fails safe.
	1. Logs relevant info.
	1. Exposes prometheus metrics.



1. Provision the infrastructure.
	1. Use IaC.
	1. Provision resources needed to run the services.
	1. Provision resources needed to view the logs and metrics of the service.



1. Package and deploy the  service. 
	1. Provide a docker file and containerize the service. 
	1. Setup a CI/CD pipeline for the service. It should build the service, 
	run the tests and deploy it.
	1. Provide a k8s manifest or use helm charts.


1. Consider the developer experience.

## Important notes

_"Wow, this is a lot!"_
We realize that not everyone is well skilled in all these technologies. 
Pick the parts you're the best at and focus on those. Show us your strengths! 
And most importantly, communicate that to us, so we can adjust our expectations accordingly.

_"Develop a service?"_
Developing the service is not the most important part of the assignment. 
You're not interviewing for a developer position. Feel free to use any language
and bootstrap framework you're most comfortable with.

_"Does it need to be production ready?"_
We'd very much like that! But, we also want to respect your time. So, be prepared
to tell us what you'd improve, should you have to deploy this into prod. 

## Delivery and Interview

Fork this repository into a public repository on your own Github profile, and 
deliver your solution there.

We will invite you to a technical interview where the solution will 
be the basis of our discussion. You will have to share your screen,
walk us through the solution and highlight what you'd like to improve. 
Moreover, we'd like to see a demo; provision infra, run the CI/CD pipeline, 
run the service and see the metrics/logs.

## Questions?
If you have questions about the task or would like us to further specify some of
the tings written above, you can contact the person who gave you the assignment.
