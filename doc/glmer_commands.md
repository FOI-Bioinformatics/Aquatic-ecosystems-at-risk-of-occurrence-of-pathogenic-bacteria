### Import the data into R.
```
prb = read.table('new_prb_170103.txt',sep='\t',header=T,row.names=1,comment='')
map = read.table('utilized_data_170103_mapping_file.txt',sep='\t',header=T,row.names=1,comment='')
prb_map = merge(prb,map,by='row.names')
rownames(prb_map) = prb_map[,1]
prb_map = prb_map[,-1]
prb_map$Treatment = as.factor(prb_map$Treatment)
prb_map$NutrientLevel = as.factor(prb_map$NutrientLevel)
prb_map$Replicate = as.factor(prb_map$Replicate)
```

```
prb.vec = c(as.matrix(prb_map[,1:3]))
n.site = dim(prb_map[,1:3])[1]
n.spp = dim(prb_map[,1:3])[2]
X = data.frame(predationpressure=rep(scale(log(prb_map$PredationPressure+0.01)),n.spp),treatment = rep(prb_map$Treatment,n.spp),day=rep(prb_map$Day,n.spp),spp = rep(relevel(as.factor(c("Mycobacterium","Rickettsia","Pseudomonas")),ref="Pseudomonas"),each=n.site),site=rep(dimnames(prb_map)[[1]],n.spp),nrreads = rep(log(prb_map$NrReads),n.spp),nutrientlevel=rep(prb_map$NutrientLevel,n.spp), identifier=rep(prb_map$Identifier,n.spp))
```

### Run the model.
```
require(lme4)
fit.glmm<-glmer(prb.vec ~ 1 + spp + predationpressure:spp + nutrientlevel:spp + (0+spp|site)+(1|treatment/identifier)+(0+day|treatment),data=X,offset=nrreads,family=poisson())
print(summary(fit.glmm),correlation=FALSE) # display results
confint(fit.glmm,method="Wald")
```
### Plot the result.
```
require(sjPlot)
sjp.lmer(fit.glmm,type='fe',vars=c('sppPseudomonas:predationpressure','sppMycobacterium:predationpressure','sppRickettsia:predationpressure','sppPseudomonas:nutrientlevel2','sppPseudomonas:nutrientlevel3','sppMycobacterium:nutrientlevel2','sppMycobacterium:nutrientlevel3','sppRickettsia:nutrientlevel2','sppRickettsia:nutrientlevel3'))
```
