class CVBrowser {
    constructor() {
        this.projectId = null;
        this.gitlabUrl = null;
        this.token = null;
        this.selectedCommit = null;
        this.commits = [];
        
        this.init();
    }
    
    async init() {
        try {
            await this.detectGitLabProject();
            await this.loadCommits();
        } catch (error) {
            this.showError('Failed to initialize: ' + error.message);
        }
    }
    
    async detectGitLabProject() {
        // Try to get from GitLab CI config first
        if (window.GITLAB_CONFIG) {
            this.projectId = window.GITLAB_CONFIG.projectId;
            this.gitlabUrl = window.GITLAB_CONFIG.gitlabUrl;
            console.log('Using GitLab CI config');
        }
        
        // Try to detect GitLab project from current URL or environment
        if (!this.projectId) {
            const currentUrl = window.location.href;
            
            // Check if we're running on GitLab Pages
            if (currentUrl.includes('.gitlab.io')) {
                // Extract project info from GitLab Pages URL
                const match = currentUrl.match(/https:\/\/([^.]+)\.gitlab\.io\/([^\/]+)/);
                if (match) {
                    const [, username, projectName] = match;
                    this.gitlabUrl = 'https://git.tana.lan';
                    this.projectId = `${username}/${projectName}`;
                }
            }
        }
        
        // Fallback: try to get from meta tags
        if (!this.projectId) {
            const metaProject = document.querySelector('meta[name="gitlab-project"]');
            const metaUrl = document.querySelector('meta[name="gitlab-url"]');
            
            if (metaProject && metaUrl) {
                this.projectId = metaProject.content;
                this.gitlabUrl = metaUrl.content;
            }
        }
        
        // Final fallback - you can hardcode your project here for local testing
        if (!this.projectId) {
            // Replace these with your actual values for local testing
            this.gitlabUrl = 'https://git.tana.lan';
            this.projectId = `gluzzati/cv`; // Update this with your actual project path
        }
        
        console.log('Detected GitLab project:', this.projectId);
        console.log('GitLab URL:', this.gitlabUrl);
    }
    
    async makeGitLabRequest(endpoint) {
        const url = `${this.gitlabUrl}/api/v4/projects/${encodeURIComponent(this.projectId)}${endpoint}`;
        
        const headers = {
            'Accept': 'application/json',
        };
        
        // Add token if available (for CI environment)
        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }
        
        console.log('Making request to:', url);
        
        const response = await fetch(url, { headers });
        
        if (!response.ok) {
            throw new Error(`GitLab API request failed: ${response.status} ${response.statusText}`);
        }
        
        return response.json();
    }
    
    async loadCommits() {
        try {
            this.showLoading();
            
            // Get commits from main branch
            const commits = await this.makeGitLabRequest('/repository/commits?ref=main&per_page=50');
            
            // Get pipeline information for each commit
            const commitsWithPipelines = await Promise.all(
                commits.map(async (commit) => {
                    try {
                        const pipelines = await this.makeGitLabRequest(`/pipelines?sha=${commit.id}`);
                        const pipeline = pipelines.length > 0 ? pipelines[0] : null;
                        
                        let hasArtifacts = false;
                        if (pipeline && pipeline.status === 'success') {
                            try {
                                const jobs = await this.makeGitLabRequest(`/pipelines/${pipeline.id}/jobs`);
                                hasArtifacts = jobs.some(job => job.artifacts && job.artifacts.length > 0);
                            } catch (e) {
                                console.warn('Could not check artifacts for pipeline', pipeline.id, e);
                            }
                        }
                        
                        return {
                            ...commit,
                            pipeline,
                            hasArtifacts
                        };
                    } catch (error) {
                        console.warn('Could not get pipeline for commit', commit.id, error);
                        return {
                            ...commit,
                            pipeline: null,
                            hasArtifacts: false
                        };
                    }
                })
            );
            
            this.commits = commitsWithPipelines;
            this.renderCommits();
            
        } catch (error) {
            this.showError('Failed to load commits: ' + error.message);
        }
    }
    
    showLoading() {
        document.getElementById('loading').style.display = 'block';
        document.getElementById('error').style.display = 'none';
        document.getElementById('commits-list').innerHTML = '';
    }
    
    showError(message) {
        document.getElementById('loading').style.display = 'none';
        document.getElementById('error').style.display = 'block';
        document.getElementById('error').textContent = message;
        console.error(message);
    }
    
    renderCommits() {
        document.getElementById('loading').style.display = 'none';
        const commitsList = document.getElementById('commits-list');
        
        if (this.commits.length === 0) {
            commitsList.innerHTML = '<p>No commits found</p>';
            return;
        }
        
        commitsList.innerHTML = this.commits.map(commit => {
            const date = new Date(commit.committed_date).toLocaleString();
            const shortSha = commit.short_id;
            const message = commit.message.split('\n')[0]; // First line only
            
            let pipelineStatus = 'unknown';
            let statusClass = 'pending';
            
            if (commit.pipeline) {
                pipelineStatus = commit.pipeline.status;
                statusClass = this.getPipelineStatusClass(pipelineStatus);
            }
            
            const hasArtifacts = commit.hasArtifacts;
            const itemClass = hasArtifacts ? 'commit-item' : 'commit-item no-artifacts';
            
            return `
                <div class="${itemClass}" data-commit-id="${commit.id}" data-has-artifacts="${hasArtifacts}">
                    <div class="commit-hash">${shortSha}</div>
                    <div class="commit-message">${this.escapeHtml(message)}</div>
                    <div class="commit-meta">
                        <span class="commit-author">${this.escapeHtml(commit.author_name)}</span>
                        <span class="commit-date">${date}</span>
                    </div>
                    <div class="pipeline-status ${statusClass}">${pipelineStatus}</div>
                </div>
            `;
        }).join('');
        
        // Add click handlers
        commitsList.querySelectorAll('.commit-item').forEach(item => {
            item.addEventListener('click', (e) => {
                const commitId = e.currentTarget.dataset.commitId;
                const hasArtifacts = e.currentTarget.dataset.hasArtifacts === 'true';
                
                if (hasArtifacts) {
                    this.selectCommit(commitId);
                }
            });
        });
    }
    
    getPipelineStatusClass(status) {
        switch (status) {
            case 'success': return 'success';
            case 'failed': return 'failed';
            case 'running': return 'running';
            case 'pending': return 'pending';
            default: return 'pending';
        }
    }
    
    async selectCommit(commitId) {
        // Update UI selection
        document.querySelectorAll('.commit-item').forEach(item => {
            item.classList.remove('selected');
        });
        
        const selectedItem = document.querySelector(`[data-commit-id="${commitId}"]`);
        if (selectedItem) {
            selectedItem.classList.add('selected');
        }
        
        this.selectedCommit = commitId;
        
        // Load PDF
        await this.loadPDF(commitId);
    }
    
    async loadPDF(commitId) {
        try {
            this.showPDFLoading();
            
            // Get the pipeline for this commit
            const commit = this.commits.find(c => c.id === commitId);
            if (!commit || !commit.pipeline) {
                throw new Error('No pipeline found for this commit');
            }
            
            // Get jobs for the pipeline
            const jobs = await this.makeGitLabRequest(`/pipelines/${commit.pipeline.id}/jobs`);
            
            // Find the compile_cv job (or the job that produces the PDF)
            const buildJob = jobs.find(job => 
                job.name === 'compile_cv' || 
                job.stage === 'build' ||
                (job.artifacts && job.artifacts.length > 0)
            );
            
            if (!buildJob) {
                throw new Error('No build job found with artifacts');
            }
            
            // The commit object has the short_id we need.
            const selectedCommit = this.commits.find(c => c.id === commitId);
            if (!selectedCommit) {
                throw new Error('Could not find commit data.');
            }

            // Construct a relative URL to the PDF that is part of the GitLab Pages deployment.
            // This avoids all CORS issues.
            const pdfUrl = `builds/cv-${selectedCommit.short_id}.pdf`;
            
            this.showPDF(pdfUrl);
            
        } catch (error) {
            this.showPDFError('Failed to load PDF: ' + error.message);
        }
    }
    
    showPDFLoading() {
        document.getElementById('welcome').style.display = 'none';
        document.getElementById('pdf-loading').style.display = 'block';
        document.getElementById('pdf-error').style.display = 'none';
        document.getElementById('pdf-container').style.display = 'none';
    }
    
    showPDFError(message) {
        document.getElementById('welcome').style.display = 'none';
        document.getElementById('pdf-loading').style.display = 'none';
        document.getElementById('pdf-error').style.display = 'block';
        document.getElementById('pdf-error').textContent = message;
        document.getElementById('pdf-container').style.display = 'none';
    }
    
    async showPDF(url) {
        document.getElementById('welcome').style.display = 'none';
        document.getElementById('pdf-loading').style.display = 'none';
        document.getElementById('pdf-error').style.display = 'none';
        
        const pdfContainer = document.getElementById('pdf-container');
        pdfContainer.style.display = 'block';
        pdfContainer.innerHTML = ''; // Clear previous PDF

        try {
            // Set worker source for PDF.js
            pdfjsLib.GlobalWorkerOptions.workerSrc = `https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js`;

            // Removed `withCredentials: true` to avoid the CORS error.
            const loadingTask = pdfjsLib.getDocument(url);
            const pdf = await loadingTask.promise;

            // Loop through all pages and render them
            for (let pageNum = 1; pageNum <= pdf.numPages; pageNum++) {
                const page = await pdf.getPage(pageNum);
                
                // Use a scale that fits well
                const desiredWidth = pdfContainer.clientWidth * 0.95;
                const viewport = page.getViewport({ scale: 1 });
                const scale = desiredWidth / viewport.width;
                const scaledViewport = page.getViewport({ scale });

                const canvas = document.createElement('canvas');
                const context = canvas.getContext('2d');
                canvas.height = scaledViewport.height;
                canvas.width = scaledViewport.width;

                pdfContainer.appendChild(canvas);

                const renderContext = {
                    canvasContext: context,
                    viewport: scaledViewport
                };
                await page.render(renderContext).promise;
            }
        } catch (error) {
            console.error('Error rendering PDF:', error);
            this.showPDFError('Failed to render PDF. Check browser console for details. A common issue is CORS policy on the GitLab server.');
        }
    }
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new CVBrowser();
}); 