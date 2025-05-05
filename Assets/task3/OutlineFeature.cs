public class OutlineFeature : ScriptableRendererFeature
{
    class OutlinePass : ScriptableRenderPass
    {
        private RenderTargetIdentifier source;
        private string profilerTag;

        public OutlinePass(string profilerTag)
        {
            this.profilerTag = profilerTag;
        }

        public void Setup(RenderTargetIdentifier source)
        {
            this.source = source;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(profilerTag);

            // Здесь можешь вставить свой рендер-шейдер/материал
            // cmd.Blit(source, destination, material);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }

    OutlinePass outlinePass;

    public override void Create()
    {
        outlinePass = new OutlinePass("Outline Pass");
        outlinePass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // ⚠️ Вот тут используем renderingData.cameraData.renderer
        var cameraColorTarget = renderer.cameraColorTargetHandle; // ✅ безопасно
        outlinePass.Setup(cameraColorTarget);
        renderer.EnqueuePass(outlinePass);
    }
}
