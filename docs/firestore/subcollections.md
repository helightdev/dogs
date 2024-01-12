To specify subcollections, you can use the 'subcollectionOf' argument of the `@Collection`
annotation. This will make the collection a subcollection of the specified entity and can only
be accessed through the parent entity.

To insert a newly created entity into a subcollection, you can use the `save` method of the
entity after linking it to the parent entity using `withParent`. 