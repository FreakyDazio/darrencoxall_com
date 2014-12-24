---
date: 2013-03-03T15:00:00Z
title: "Boxen and My Experience"
type: post
aliases:
  - /web-development/boxen-and-my-experience/
---

[Boxen] is a new tool that allows new Macs to be quickly set-up using the same technologies that sysops have become accustomed to, Puppet. Now Puppet has it's own language to define what actions are executed on target machine. It was originally developed to help prepare *cloud* servers for easier management/deployment.

The popularity of Puppet has increased and it has become a widely used tool and so the team over at [github.com][github] decided to build a system that utilises it to perform similar setup tasks on Macs.

I have only spent a couple of days using Boxen but it has given me some fairly strong opinion. Before I dive in with my thoughts I must own up to *(still)* not completely understanding the Puppet language and this is likely a large cause of many of my issues.

## Developing for Boxen

Getting started with Boxen is quick and easy. Following the provided instructions works perfectly. The pre-made puppet classes and libraries developed for Boxen all seem to work brilliantly. I had only minor issues with 1 of the repos but this was easy to get around.

The difficulty comes when creating your own Puppet modules. I had trouble figuring out how to test that the documents worked as expected. Running boxen, having it install multiple pieces of software and tools only for it to fail near the end. This wouldn't be so bad but a couple of pre-flight checks built into Boxen meant I would have to uninstall the software to retry. This became a pain. Many of you may read this and think:

> Why not just remove the checks? It's all open source after all.

It's easy enough to do. A project search shows where the checks are performed but this requires direct modification of the Boxen tool as opposed to the configuration. It becomes less configuration and more alteration of the tool itself which I was a little *un-comfortable* with.

There are gems that come with Boxen to help provide tests but I couldn't get them to work as expected and with little to no documentation on testing boxen configurations I had to abandon a proper set of tests for just manually running the tool.

## Existing Puppet Modules

As previously stated there are many existing puppet modules developed for use with Boxen. They work well and are very easy to use but none are very configurable *(with my experience)* and their documentation is all very poor.

Many of the modules such as [MongoDB] and [Redis] are set-up to install on non-standard ports which is a little confusing initially. I understand why they have done so but to change these ports you need to fork or create your own module to make just a single change of port.

The architecture of Boxen lends itself to having multiple repos for each of your modules and using `include` to pull them into your Boxen script. This works well when you have a lot of repositories available but when it is aimed at companies that will often have unique configuration requirements then this can lead to an excess of fairly simple repos being used up. *This may well be addressed with a better understanding of the Puppet language however.*

### Final Thoughts

My personal experience only highlights my lack of Puppet knowledge but even after my initial difficulties I was able to get all the required tools and software installed through Boxen. It dramatically reduces the set-up time for new development machines allowing new members to get started considerably faster than before.

I am now far more interested in learning Puppet to better make use of Boxen as I think it has massive potential. It would be an astonishing tool if/once it can handle a variety of Operating Systems as opposed to only Macs.

Even with my somewhat limited understanding, I was still left with a positive opinion. I think this could eventually be the go-to tool for systems teams in organisations and even now it makes the task of installing development dependencies much easier.

I suggest you give it a try.

[boxen]: https://github.com/boxen "Boxen"
[github]: https://github.com/ "GitHub"
[mongodb]: https://github.com/boxen/puppet-mongodb "Puppet MongoDB"
[redis]: https://github.com/boxen/puppet-redis "Puppet Redis"
