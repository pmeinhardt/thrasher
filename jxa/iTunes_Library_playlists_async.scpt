JsOsaDAS1.001.00bplist00�Vscripto� / /   m a c O S   S i e r r a   u s e s   a   J a v a S c r i p t C o r e   a n a l a g o u s   t o   t h a t   i n   S a f a r i   1 0 . 1 .   T h i s   s u p p o r t s   a l l   o f 
 / /   E C M A S c r i p t   2 0 1 5   (  E S 6  ) ,   a n d   e v e n   m u c h   o f   E C M A S c r i p t   2 0 1 6 !   F o r   i n s t a n c e ,   t r y   ` a s y n c `   
 
 a s y n c   f u n c t i o n   p l a y l i s t s T r a c k s ( p l a y l i s t s ) { 
 	 	 f u n c t i o n   f l a t t e n ( a r r )   { 
     	 	 	 r e t u r n   A r r a y . p r o t o t y p e . c o n c a t . a p p l y ( [ ] ,   a r r ) ; 
 	 	 } 
 	 
 	 	 v a r   p l   =   f l a t t e n ( p l a y l i s t s . m a p (   p   = >   { 
 	 	 	 l e t   t r a c k s     =   p . t r a c k s ( ) ; 
 	 	 	 r e t u r n   t r a c k s . m a p (   t   = >   { 
 	 	 	 	 c o n s o l e . l o g ( t . i d ( ) ,   t . n a m e ( ) ,   p . n a m e ( ) ) ; 
 	 	 	 	 r e t u r n   { i d :   t . i d ( ) ,   n a m e :   t . n a m e ( ) ,   c o l l e c t i o n :   p . n a m e ( ) ,   a r t i s t :   t . a r t i s t ( ) } 
 	 	   } )   } ) ) 
       	 	 r e t u r n   p l ; 
 } 
 	 
 f u n c t i o n   r u n ( a r g v )   { 
 	 c o n s t   i t u n e s   =   A p p l i c a t i o n ( ' i T u n e s ' ) ; 
 	 c o n s t   l i b r a r y   =   i t u n e s . s o u r c e s [ ' L i b r a r y ' ] ; 
 	 c o n s t   p l a y l i s t s   =   l i b r a r y . u s e r P l a y l i s t s ( ) . f i l t e r ( p l a y l i s t   = >   { 
 	 	 r e t u r n   p l a y l i s t . d u r a t i o n ( )   >   0 ;   } ) ; 
     	 v a r   t   =   p l a y l i s t s T r a c k s ( p l a y l i s t s ) ; 
 
     	 i f   ( ! ( t   i n s t a n c e o f   P r o m i s e ) )   t h r o w   " N o   E S 2 0 1 6   s u p p o r t . " 
 
     	 t . t h e n ( r e s u l t   = >   c o n s o l e . l o g ( r e s u l t   +   "   ( a s y n c ! ) " )   ) 
 } 
                              Xjscr  ��ޭ