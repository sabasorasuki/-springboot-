<template>
  <div class="profile-page">
    <div v-if="pageLoading" class="page-loading">
      <i class="el-icon-loading" />
      <span>个人中心加载中…</span>
    </div>

    <el-empty
      v-else-if="pageError"
      :description="pageError"
      :image-size="120"
    />

    <div v-else-if="profile" class="profile-layout">
      <section class="profile-banner">
        <div class="profile-banner__surface">
          <img
            v-if="profileCoverImage"
            :src="profileCoverImage"
            alt=""
            class="profile-banner__cover-img"
          >
          <div v-else class="profile-banner__fallback">
            <span>{{ isSelf ? '上传背景图，让你的主页更完整' : 'TA 还没有设置头图' }}</span>
          </div>
          <div class="profile-banner__overlay" />
        </div>
      </section>

      <div class="profile-container">
        <section class="profile-header">
          <div class="profile-left">
            <div class="profile-avatar">
              <img
                v-if="profileAvatar"
                :src="profileAvatar"
                alt=""
                class="profile-avatar__image"
              >
              <i v-else class="el-icon-user profile-avatar__fallback-icon" />
            </div>

            <div class="profile-meta">
              <h1 class="profile-name">{{ profileDisplayName }}</h1>

              <div class="profile-handle-row">
                <span v-if="profile.username" class="profile-handle">@{{ profile.username }}</span>
                <span v-if="locationText" class="profile-location">
                  <i class="el-icon-location-outline" />
                  {{ locationText }}
                </span>
                <span
                  v-for="tag in styleTagList"
                  :key="tag"
                  class="profile-inline-tag"
                >
                  {{ tag }}
                </span>
              </div>

              <div class="profile-stats">
                <button type="button" class="profile-stat is-link" @click="goFollows">
                  <span class="profile-stat__value">{{ followStats.following }}</span>
                  <span class="profile-stat__label">{{ isSelf ? '已关注' : '关注' }}</span>
                </button>

                <button type="button" class="profile-stat is-link" @click="goFollows">
                  <span class="profile-stat__value">{{ followStats.followers }}</span>
                  <span class="profile-stat__label">粉丝</span>
                </button>

                <div class="profile-stat">
                  <span class="profile-stat__value">{{ portfolioCount }}</span>
                  <span class="profile-stat__label">{{ portfolioLabel }}</span>
                </div>
              </div>

              <p class="profile-bio" :class="{ 'is-empty': !profile.bio }">
                {{ profile.bio || '这个人还没有留下简介。' }}
              </p>
            </div>
          </div>

          <div class="profile-actions">
            <div class="profile-actions__primary">
              <el-button
                v-if="isSelf"
                plain
                size="small"
                class="profile-action-btn"
                @click="openEditDialog"
              >
                编辑个人信息
              </el-button>

              <el-button
                v-if="!isSelf"
                size="small"
                class="profile-action-btn"
                :type="isFollowingProfile ? '' : 'primary'"
                :plain="isFollowingProfile"
                :loading="followLoading"
                @click="toggleFollowProfile"
              >
                {{ isFollowingProfile ? '已关注' : '关注' }}
              </el-button>
            </div>

            <div class="profile-action-switch">
              <span class="profile-action-switch__label">{{ isSelf ? '身份切换' : '查看身份' }}</span>
              <el-radio-group v-model="profileViewModeValue" size="small">
                <el-radio-button label="artist">画师</el-radio-button>
                <el-radio-button label="client">用户</el-radio-button>
              </el-radio-group>
            </div>
          </div>
        </section>

        <section class="profile-tabs-wrap">
          <nav class="profile-tabs" aria-label="个人中心分类">
            <button
              v-for="tab in primaryTabs"
              :key="tab.key"
              type="button"
              class="profile-tabs__item"
              :class="{ 'is-active': activePrimaryTab === tab.key }"
              @click="setPrimaryTab(tab.key)"
            >
              {{ tab.label }}
            </button>
          </nav>

          <div v-if="secondaryTabs.length" class="profile-subtabs">
            <button
              v-for="tab in secondaryTabs"
              :key="tab.key"
              type="button"
              class="profile-subtabs__item"
              :class="{ 'is-active': activeSecondaryTab === tab.key }"
              @click="setSecondaryTab(tab.key)"
            >
              {{ tab.label }}
            </button>
          </div>
        </section>

        <section class="profile-content">
          <template v-if="isSelf">
            <section v-if="activePrimaryTab === 'submissions'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">我的投稿</h2>
                  <p class="section-heading__desc">画师身份下管理自己的作品与橱窗。</p>
                </div>
                <el-button
                  size="small"
                  type="primary"
                  @click="goPublishEntry(activeSecondaryTab)"
                >
                  {{ activeSecondaryTab === 'showcase' ? '发布橱窗' : '发布作品' }}
                </el-button>
              </div>

              <div v-if="activeSecondaryTab === 'works'">
                <div v-if="works.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                <div v-else-if="works.list.length" class="card-grid">
                  <article
                    v-for="item in works.list"
                    :key="item.id"
                    class="content-card is-clickable"
                    @click="openWorkPreview(item)"
                  >
                    <div class="content-card__cover">
                      <img
                        v-if="item.photoUrl && !item.photoBroken"
                        :src="item.photoUrl"
                        alt=""
                        class="cover-img"
                        @error="handleCardImageError(item)"
                      >
                      <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                    </div>
                    <div class="content-card__body">
                      <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                      <div class="content-card__meta">
                        <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        <span v-if="item.fbdate" class="meta-note">{{ item.fbdate }}</span>
                      </div>
                    </div>
                  </article>
                </div>
                <el-empty v-else description="还没有投稿作品" :image-size="110" />
              </div>

              <div v-else>
                <div v-if="showcase.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                <div v-else-if="showcase.list.length" class="card-grid">
                  <article
                    v-for="item in showcase.list"
                    :key="item.id"
                    class="content-card is-clickable"
                    @click="goShowcaseDetail(item.id)"
                  >
                    <div class="content-card__cover">
                      <img
                        v-if="item.photoUrl && !item.photoBroken"
                        :src="item.photoUrl"
                        alt=""
                        class="cover-img"
                        @error="handleCardImageError(item)"
                      >
                      <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                      <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                    </div>
                    <div class="content-card__body">
                      <div class="content-card__title">{{ item.name || '未命名橱窗' }}</div>
                      <div class="content-card__meta">
                        <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        <span v-if="item.status" class="meta-note">{{ item.status }}</span>
                      </div>
                    </div>
                  </article>
                </div>
                <el-empty v-else description="还没有橱窗投稿" :image-size="110" />
              </div>
            </section>

            <section v-else-if="activePrimaryTab === 'projects'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">我的企划</h2>
                  <p class="section-heading__desc">用户身份下查看和管理自己发布的企划。</p>
                </div>
                <el-button size="small" type="primary" @click="goPublishEntry('projects')">发布企划</el-button>
              </div>

              <div v-if="projects.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="projects.list.length" class="project-list">
                <article
                  v-for="item in projects.list"
                  :key="item.id"
                  class="project-card is-clickable"
                  @click="goProjectDetail(item.id)"
                >
                  <div class="project-card__main">
                    <div class="project-card__title">{{ item.title }}</div>
                    <p class="project-card__desc">{{ item.description || '暂无企划描述' }}</p>
                  </div>
                  <div class="project-card__side">
                    <span v-if="item.status" class="project-status">{{ item.status }}</span>
                    <span class="project-budget">{{ formatBudget(item) }}</span>
                  </div>
                </article>
              </div>
              <el-empty v-else description="还没有发布企划" :image-size="110" />
            </section>

            <section v-else-if="activePrimaryTab === 'favorites'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">我的收藏</h2>
                  <p class="section-heading__desc">
                    {{ isArtistView ? '画师身份下只展示收藏的企划。' : '用户身份下按作品与橱窗分类查看收藏。' }}
                  </p>
                </div>
              </div>

              <div v-if="favorites.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <template v-else>
                <div v-if="activeSecondaryTab === 'projects'">
                  <div v-if="favoriteProjects.length" class="project-list">
                    <article
                      v-for="item in favoriteProjects"
                      :key="item.id"
                      class="project-card is-clickable"
                      @click="goProjectDetail(item.wzids)"
                    >
                      <div class="project-card__main">
                        <div class="project-card__title">{{ item.title || '未命名企划' }}</div>
                        <p class="project-card__desc">收藏的企划条目</p>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏企划" :image-size="110" />
                </div>

                <div v-else-if="activeSecondaryTab === 'works'">
                  <div v-if="favoriteWorks.length" class="card-grid">
                    <article v-for="item in favoriteWorks" :key="item.id" class="content-card">
                      <div class="content-card__cover">
                        <img
                          v-if="item.photoUrl && !item.photoBroken"
                          :src="item.photoUrl"
                          alt=""
                          class="cover-img"
                          @error="handleCardImageError(item)"
                        >
                        <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                      </div>
                      <div class="content-card__body">
                        <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                        <div class="content-card__meta">
                          <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        </div>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏作品" :image-size="110" />
                </div>

                <div v-else>
                  <div v-if="favoriteShowcase.length" class="card-grid">
                    <article
                      v-for="item in favoriteShowcase"
                      :key="item.id"
                      class="content-card is-clickable"
                      @click="goShowcaseDetail(item.wzids)"
                    >
                      <div class="content-card__cover">
                        <img
                          v-if="item.photoUrl && !item.photoBroken"
                          :src="item.photoUrl"
                          alt=""
                          class="cover-img"
                          @error="handleCardImageError(item)"
                        >
                        <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                        <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                      </div>
                      <div class="content-card__body">
                        <div class="content-card__title">{{ item.title || '未命名橱窗' }}</div>
                        <div class="content-card__meta">
                          <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        </div>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏橱窗" :image-size="110" />
                </div>
              </template>
            </section>

            <section v-else-if="activePrimaryTab === 'cart'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">购物车</h2>
                  <p class="section-heading__desc">这里只展示加入购物车的橱窗商品。</p>
                </div>
                <el-button size="small" plain @click="$router.push('/showcase')">去逛橱窗</el-button>
              </div>

              <div v-if="cart.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="cart.list.length" class="stack-list">
                <article v-for="item in cart.list" :key="item.id" class="stack-card">
                  <img
                    v-if="item.photoUrl && !item.photoBroken"
                    :src="item.photoUrl"
                    class="stack-card__thumb"
                    alt=""
                    @error="handleCardImageError(item)"
                  >
                  <div v-else class="stack-card__thumb stack-card__thumb--empty">
                    <span class="stack-card__thumb-label">暂无封面</span>
                  </div>
                  <div class="stack-card__main">
                    <div class="stack-card__title">{{ item.name || '未命名商品' }}</div>
                    <div class="stack-card__meta">
                      <span class="price-text">¥{{ item.price || 0 }}</span>
                      <span v-if="item.xddate" class="meta-note">{{ item.xddate }}</span>
                    </div>
                  </div>
                  <div class="stack-card__actions">
                    <el-button size="mini" type="primary" @click="openOrdersTab">去支付</el-button>
                    <el-button size="mini" type="text" @click="removeCartItem(item)">移除</el-button>
                  </div>
                </article>
              </div>
              <el-empty v-else description="购物车还是空的" :image-size="110" />
            </section>

            <section v-else class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">订单</h2>
                  <p class="section-heading__desc">统一查看买家或画师视角下的订单记录。</p>
                </div>

                <el-radio-group
                  v-if="hasArtistRole"
                  v-model="orderViewRole"
                  size="small"
                >
                  <el-radio-button label="用户角色">买家</el-radio-button>
                  <el-radio-button label="画师角色">画师</el-radio-button>
                </el-radio-group>
              </div>

              <div v-if="orders.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <el-table v-else-if="orders.list.length" :data="orders.list" class="orders-table">
                <el-table-column prop="name" label="订单内容" min-width="160" show-overflow-tooltip />
                <el-table-column label="价格" width="110">
                  <template slot-scope="{ row }">
                    <span class="price-text">¥{{ row.price || 0 }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="status" label="状态" width="120">
                  <template slot-scope="{ row }">
                    <el-tag size="small" :type="statusTagType(row.status)">{{ row.status }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="xddate" label="时间" min-width="160" />
              </el-table>
              <el-empty v-else description="还没有订单记录" :image-size="110" />
            </section>
          </template>

          <template v-else>
            <section v-if="activePrimaryTab === 'featuredWorks'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">精选作品</h2>
                  <p class="section-heading__desc">以画师身份查看该用户公开展示的作品。</p>
                </div>
              </div>

              <div v-if="works.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="works.list.length" class="card-grid">
                <article
                  v-for="item in works.list"
                  :key="item.id"
                  class="content-card is-clickable"
                  @click="openWorkPreview(item)"
                >
                  <div class="content-card__cover">
                    <img
                      v-if="item.photoUrl && !item.photoBroken"
                      :src="item.photoUrl"
                      alt=""
                      class="cover-img"
                      @error="handleCardImageError(item)"
                    >
                    <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                  </div>
                  <div class="content-card__body">
                    <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                    <div class="content-card__meta">
                      <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                    </div>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开作品" :image-size="110" />
            </section>

            <section v-else-if="activePrimaryTab === 'showcase'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">橱窗</h2>
                  <p class="section-heading__desc">以画师身份查看该用户公开上架的橱窗内容。</p>
                </div>
              </div>

              <div v-if="showcase.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="showcase.list.length" class="card-grid">
                <article
                  v-for="item in showcase.list"
                  :key="item.id"
                  class="content-card is-clickable"
                  @click="goShowcaseDetail(item.id)"
                >
                  <div class="content-card__cover">
                    <img
                      v-if="item.photoUrl && !item.photoBroken"
                      :src="item.photoUrl"
                      alt=""
                      class="cover-img"
                      @error="handleCardImageError(item)"
                    >
                    <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                    <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                  </div>
                  <div class="content-card__body">
                    <div class="content-card__title">{{ item.name || '未命名橱窗' }}</div>
                    <div class="content-card__meta">
                      <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                    </div>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开橱窗" :image-size="110" />
            </section>

            <section v-else class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">企划</h2>
                  <p class="section-heading__desc">以用户身份查看该用户公开发布的企划。</p>
                </div>
              </div>

              <div v-if="projects.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="projects.list.length" class="project-list">
                <article
                  v-for="item in projects.list"
                  :key="item.id"
                  class="project-card is-clickable"
                  @click="goProjectDetail(item.id)"
                >
                  <div class="project-card__main">
                    <div class="project-card__title">{{ item.title }}</div>
                    <p class="project-card__desc">{{ item.description || '暂无企划描述' }}</p>
                  </div>
                  <div class="project-card__side">
                    <span v-if="item.status" class="project-status">{{ item.status }}</span>
                    <span class="project-budget">{{ formatBudget(item) }}</span>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开企划" :image-size="110" />
            </section>
          </template>
        </section>

        <el-dialog
          :visible.sync="workPreviewVisible"
          :title="null"
          width="680px"
          custom-class="profile-work-preview-dialog"
          :show-close="true"
          append-to-body
        >
          <div v-if="previewWorkItem" class="profile-preview-content">
            <div class="profile-preview-image">
              <img
                v-if="previewWorkItem.photoUrl && !previewWorkItem.photoBroken"
                :src="previewWorkItem.photoUrl"
                alt=""
                class="profile-preview-img"
                @error="handlePreviewImageError"
              >
              <div v-else class="profile-preview-image__placeholder">
                <span>暂无可预览图片</span>
              </div>

              <div v-if="previewCanDelete" class="profile-preview-image__actions">
                <el-button
                  size="mini"
                  class="profile-preview-delete-btn"
                  :loading="previewDeleteLoading"
                  @click.stop="handleDeletePreviewWork"
                >
                  删除作品
                </el-button>
              </div>
            </div>

            <div class="profile-preview-info">
              <div class="profile-preview-author" @click="goPreviewAuthor">
                <img
                  :src="profileAvatar || defaultAvatar"
                  class="profile-preview-author__avatar"
                  alt=""
                >
                <span class="profile-preview-author__name">{{ profileDisplayName }}</span>
              </div>
              <h2 v-if="previewWorkItem.title" class="profile-preview-title">{{ previewWorkItem.title }}</h2>
              <div v-if="previewWorkItem.fenlei || previewWorkItem.fbdate" class="profile-preview-tags">
                <span v-if="previewWorkItem.fenlei" class="meta-tag">{{ previewWorkItem.fenlei }}</span>
                <span v-if="previewWorkItem.fbdate" class="meta-note">{{ previewWorkItem.fbdate }}</span>
              </div>
              <p v-if="previewWorkItem.content" class="profile-preview-desc">{{ previewWorkItem.content }}</p>
            </div>
          </div>
        </el-dialog>

        <el-dialog
          :visible.sync="editDialogVisible"
          title="编辑个人信息"
          width="720px"
          destroy-on-close
        >
          <el-form ref="editForm" :model="editForm" label-width="84px" class="edit-form">
            <div class="edit-form__hint">在同一个面板里完成基础资料、头像和头图调整。上传完成后点击保存，即会同步刷新个人中心和顶栏头像。</div>
            <div class="edit-media-grid">
              <section class="edit-media-card edit-media-card--avatar">
                <div class="edit-media-card__header">
                  <span class="edit-media-card__title">头像</span>
                  <span class="edit-media-card__desc">上传后可裁剪调整，保存后生效</span>
                </div>
                <div class="edit-avatar-preview">
                  <img v-if="editAvatarPreview" :src="editAvatarPreview" alt="" class="edit-avatar-preview__img">
                  <div v-else class="edit-avatar-preview__placeholder">暂无头像</div>
                </div>
                <el-upload
                  class="edit-upload"
                  action="#"
                  :auto-upload="false"
                  :show-file-list="false"
                  :on-change="onAvatarFileChange"
                  accept="image/*"
                >
                  <el-button size="small" plain>选择头像</el-button>
                </el-upload>
              </section>

              <section class="edit-media-card edit-media-card--cover">
                <div class="edit-media-card__header">
                  <span class="edit-media-card__title">背景图</span>
                  <span class="edit-media-card__desc">建议横向图片，上传后可裁剪调整</span>
                </div>
                <div class="edit-cover-preview" :style="editCoverPreviewStyle">
                  <div class="edit-cover-preview__mask" />
                  <span v-if="!editCoverPreview" class="edit-cover-preview__placeholder">暂无背景图</span>
                </div>
                <el-upload
                  class="edit-upload"
                  action="#"
                  :auto-upload="false"
                  :show-file-list="false"
                  :on-change="onCoverFileChange"
                  accept="image/*"
                >
                  <el-button size="small" plain>选择背景图</el-button>
                </el-upload>
              </section>
            </div>
            <el-form-item label="用户名">
              <el-input v-model="editForm.username" disabled />
            </el-form-item>
            <el-form-item label="昵称">
              <el-input v-model="editForm.name" placeholder="请输入昵称" />
            </el-form-item>
            <el-form-item v-if="locationText" label="地区">
              <el-input :value="locationText" disabled />
            </el-form-item>
            <el-form-item label="邮箱">
              <el-input v-model="editForm.email" placeholder="请输入邮箱" />
            </el-form-item>
            <el-form-item label="电话">
              <el-input v-model="editForm.phone" placeholder="请输入电话" />
            </el-form-item>
            <el-form-item label="简介">
              <el-input
                v-model="editForm.bio"
                type="textarea"
                :rows="4"
                maxlength="500"
                show-word-limit
                placeholder="介绍一下自己"
              />
            </el-form-item>
            <el-form-item label="风格标签">
              <el-input
                v-model="editForm.styleTags"
                placeholder="多个标签用逗号分隔，例如：国风,厚涂,Q版"
              />
            </el-form-item>
          </el-form>

          <div slot="footer" class="dialog-footer">
            <el-button @click="editDialogVisible = false">取消</el-button>
            <el-button type="primary" :loading="saving" @click="handleSaveProfile">保存</el-button>
          </div>
        </el-dialog>

        <el-dialog
          :visible.sync="cropperVisible"
          :title="cropperMode === 'avatar' ? '裁剪头像' : '裁剪背景图'"
          :width="cropperMode === 'avatar' ? '480px' : '720px'"
          append-to-body
          destroy-on-close
          @closed="onCropperClosed"
        >
          <div class="cropper-container">
            <vue-cropper
              ref="cropper"
              :img="cropperImageUrl"
              :output-size="1"
              output-type="png"
              :auto-crop="true"
              :auto-crop-width="cropperMode === 'avatar' ? 400 : 1200"
              :auto-crop-height="cropperMode === 'avatar' ? 400 : 400"
              :fixed="true"
              :fixed-number="cropperMode === 'avatar' ? [1, 1] : [3, 1]"
              :center-box="true"
              :can-move-box="true"
              :can-scale="true"
              :full="true"
              :high="true"
              :enlarge="2"
            />
          </div>
          <div slot="footer" class="dialog-footer">
            <el-button @click="cropperVisible = false">取消</el-button>
            <el-button type="primary" :loading="cropperUploading" @click="handleCropConfirm">确认并上传</el-button>
          </div>
        </el-dialog>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import axios from 'axios'
import { VueCropper } from 'vue-cropper'
import userApi from '@/api/userManage'
import followApi from '@/api/follow'
import fenxiangApi from '@/api/fenxiang'
import huagaoApi from '@/api/huagao'
import projectApi from '@/api/project'
import shoucangApi from '@/api/shoucang'
import orderApi from '@/api/order'
import { extractUploadFileName, normalizeImageUrl, ossUploadAction } from '@/utils/oss'
import {
  buildCenterProfileRoute,
  buildOtherArtistProfileRoute,
  getCenterProfileConfig,
  normalizeProfileViewMode,
  resolveCenterProfileState
} from '@/utils/centerProfile'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

function createListState(pageSize = 8) {
  return {
    list: [],
    total: 0,
    pageNo: 1,
    pageSize,
    loading: false,
    loaded: false
  }
}

function isSameRouteQueryValue(left, right) {
  return (left || '') === (right || '')
}

function isSameProfileLocation(route, target) {
  const currentQuery = route.query || {}
  const targetQuery = target.query || {}

  return route.path === target.path &&
    isSameRouteQueryValue(currentQuery.view, targetQuery.view) &&
    isSameRouteQueryValue(currentQuery.tab, targetQuery.tab) &&
    isSameRouteQueryValue(currentQuery.sub, targetQuery.sub)
}

export default {
  name: 'CenterProfile',
  components: { VueCropper },
  data() {
    return {
      defaultAvatar,
      pageLoading: true,
      pageError: '',
      currentUser: null,
      profile: null,
      profileUserId: null,
      isSelf: false,
      otherDisplayMode: 'artist',
      editDialogVisible: false,
      saving: false,
      avatarUploading: false,
      coverUploading: false,
      followLoading: false,
      isFollowingProfile: false,
      cropperVisible: false,
      cropperMode: 'avatar',
      cropperImageUrl: '',
      cropperUploading: false,
      workPreviewVisible: false,
      previewWorkItem: null,
      previewDeleteLoading: false,
      editForm: {
        id: null,
        username: '',
        name: '',
        email: '',
        phone: '',
        bio: '',
        styleTags: '',
        avatar: '',
        coverImage: ''
      },
      followStats: {
        following: 0,
        followers: 0
      },
      activePrimaryTab: 'submissions',
      activeSecondaryTab: 'works',
      orderViewRole: '用户角色',
      works: createListState(),
      showcase: createListState(),
      projects: createListState(),
      favorites: createListState(99),
      cart: createListState(6),
      orders: createListState(6)
    }
  },
  computed: {
    ...mapGetters(['token', 'userId', 'displayMode', 'roles']),
    profileViewModeValue: {
      get() {
        return this.isSelf
          ? normalizeProfileViewMode(this.displayMode, 'client')
          : this.otherDisplayMode
      },
      set(nextMode) {
        this.handleProfileModeChange(nextMode)
      }
    },
    hasArtistRole() {
      return Array.isArray(this.roles) && this.roles.includes('画师角色')
    },
    currentViewMode() {
      return this.isSelf
        ? normalizeProfileViewMode(this.displayMode, 'client')
        : this.otherDisplayMode
    },
    isArtistView() {
      return this.currentViewMode === 'artist'
    },
    previewCanDelete() {
      return this.isSelf && !!(this.previewWorkItem && this.previewWorkItem.id)
    },
    profileSchema() {
      return getCenterProfileConfig(this.isSelf, this.currentViewMode)
    },
    profileDisplayName() {
      if (!this.profile) return '用户'
      return this.profile.name || this.profile.username || '用户'
    },
    profileAvatar() {
      return normalizeImageUrl(this.profile && this.profile.avatar) || this.defaultAvatar
    },
    profileCoverImage() {
      if (!this.profile) return ''
      return normalizeImageUrl(this.profile.coverImage || this.profile.cover || this.profile.backgroundImage || this.profile.background)
    },
    editAvatarPreview() {
      return normalizeImageUrl(this.editForm.avatar) || this.profileAvatar
    },
    editCoverPreview() {
      return normalizeImageUrl(this.editForm.coverImage) || this.profileCoverImage
    },
    editCoverPreviewStyle() {
      if (!this.editCoverPreview) {
        return {}
      }
      return {
        backgroundImage: `linear-gradient(135deg, rgba(14, 29, 41, 0.14), rgba(14, 29, 41, 0.38)), url("${this.editCoverPreview}")`
      }
    },
    locationText() {
      if (!this.profile) return ''
      return this.profile.location || this.profile.region || this.profile.address || ''
    },
    portfolioCount() {
      if (this.currentViewMode === 'artist') {
        return this.works.total + this.showcase.total
      }
      return this.projects.total
    },
    portfolioLabel() {
      if (this.currentViewMode === 'artist') {
        return this.isSelf ? '投稿数' : '作品数'
      }
      return '企划数'
    },
    primaryTabs() {
      return this.profileSchema.primaryTabs || []
    },
    secondaryTabs() {
      return (this.profileSchema.secondaryTabs[this.activePrimaryTab] || []).map(item => ({ ...item }))
    },
    favoriteWorks() {
      return this.favorites.list.filter(item => (!item.price || Number(item.price) === 0) && item.fenlei !== '企划')
    },
    favoriteShowcase() {
      return this.favorites.list.filter(item => item.price && Number(item.price) > 0)
    },
    favoriteProjects() {
      return this.favorites.list.filter(item => item.fenlei === '企划')
    },
    styleTagList() {
      const rawTags = (this.profile && this.profile.styleTags) || ''
      return rawTags
        .split(/[,，]/)
        .map(tag => tag.trim())
        .filter(Boolean)
        .slice(0, 6)
    }
  },
  watch: {
    '$route.fullPath': {
      immediate: true,
      handler() {
        this.handleRouteChange()
      }
    },
    orderViewRole(newValue, oldValue) {
      if (newValue !== oldValue && this.isSelf && this.activePrimaryTab === 'orders') {
        this.orders.pageNo = 1
        this.fetchOrders()
      }
    }
  },
  activated() {
    this.applyPageChrome()
  },
  deactivated() {
    this.clearPageChrome()
  },
  mounted() {
    this.applyPageChrome()
  },
  beforeDestroy() {
    this.clearPageChrome()
  },
  methods: {
    ossUploadAction,
    applyPageChrome() {
      document.body.classList.add('profile-page-view')
    },
    clearPageChrome() {
      document.body.classList.remove('profile-page-view')
    },
    async handleRouteChange() {
      const previousProfileUserId = this.profileUserId
      const previousIsSelf = this.isSelf

      try {
        await this.ensureCurrentUser()

        const context = this.resolveProfileContext()
        if (context.shouldCanonicalizeSelfPath) {
          this.replaceProfileRoute({
            viewMode: this.$route.query.view || normalizeProfileViewMode(this.displayMode, 'client'),
            tab: this.$route.query.tab,
            sub: this.$route.query.sub
          })
          return
        }

        const shouldReloadProfile = !this.profile ||
          previousProfileUserId !== context.profileUserId ||
          previousIsSelf !== context.isSelf

        if (shouldReloadProfile) {
          this.pageLoading = true
          this.pageError = ''
          this.profile = null
          this.profileUserId = context.profileUserId
          this.isSelf = context.isSelf
          this.isFollowingProfile = false
          this.followLoading = false
          this.editDialogVisible = false
          this.resetContentState()

          if (context.isSelf) {
            this.profile = { ...this.currentUser }
            this.orderViewRole = this.getDefaultOrderRole(normalizeProfileViewMode(this.displayMode, 'client'))
          } else {
            this.profile = await this.fetchOtherProfile(context.profileUserId)
            this.orderViewRole = '用户角色'
          }

          this.applyProfileToForm(this.profile)

          await Promise.all([
            this.fetchFollowStats(),
            this.fetchWorks(),
            this.fetchShowcase(),
            this.fetchProjects()
          ])

          if (!context.isSelf) {
            await this.checkFollowStatus()
          }
        }

        this.applyRouteState()
        this.ensureSectionData()
      } catch (error) {
        this.pageError = error && error.message ? error.message : '个人中心加载失败'
      } finally {
        this.pageLoading = false
      }
    },
    resolveProfileContext() {
      const routeId = this.normalizeUserId(this.$route.params.id)
      const currentUserId = this.currentUser && this.currentUser.id ? Number(this.currentUser.id) : null

      if (!routeId) {
        if (!currentUserId) {
          throw new Error('请先登录后再查看个人中心')
        }
        return {
          isSelf: true,
          profileUserId: currentUserId,
          shouldCanonicalizeSelfPath: false
        }
      }

      if (currentUserId && routeId === currentUserId) {
        return {
          isSelf: true,
          profileUserId: currentUserId,
          shouldCanonicalizeSelfPath: true
        }
      }

      return {
        isSelf: false,
        profileUserId: routeId,
        shouldCanonicalizeSelfPath: false
      }
    },
    resolveDefaultOtherViewMode() {
      if (this.projects.total > 0 && this.works.total === 0 && this.showcase.total === 0) {
        return 'client'
      }
      return 'artist'
    },
    applyRouteState() {
      const fallbackMode = this.isSelf
        ? normalizeProfileViewMode(this.displayMode, 'client')
        : this.resolveDefaultOtherViewMode()
      const resolvedState = resolveCenterProfileState({
        isSelf: this.isSelf,
        viewMode: this.$route.query.view || fallbackMode,
        tab: this.$route.query.tab,
        sub: this.$route.query.sub
      })

      if (this.isSelf) {
        const nextMode = normalizeProfileViewMode(resolvedState.viewMode, 'client')
        if (nextMode !== this.displayMode) {
          this.$store.commit('user/SET_DISPLAY_MODE', nextMode)
        }
        this.orderViewRole = this.getDefaultOrderRole(nextMode)
      } else {
        this.otherDisplayMode = resolvedState.viewMode
      }

      this.activePrimaryTab = resolvedState.tab
      this.activeSecondaryTab = resolvedState.sub

      this.replaceProfileRoute(resolvedState)
    },
    getDefaultOrderRole(viewMode) {
      return viewMode === 'artist' && this.hasArtistRole ? '画师角色' : '用户角色'
    },
    replaceProfileRoute(state) {
      const target = buildCenterProfileRoute({
        isSelf: this.isSelf,
        userId: this.isSelf ? null : this.profileUserId,
        viewMode: state.viewMode || this.currentViewMode,
        tab: state.tab || this.activePrimaryTab,
        sub: Object.prototype.hasOwnProperty.call(state, 'sub') ? state.sub : this.activeSecondaryTab
      })

      if (!isSameProfileLocation(this.$route, target)) {
        this.$router.replace(target).catch(() => {})
      }
    },
    resetContentState() {
      this.works = createListState()
      this.showcase = createListState()
      this.projects = createListState()
      this.favorites = createListState(99)
      this.cart = createListState(6)
      this.orders = createListState(6)
      this.closeWorkPreview()
    },
    normalizeUserId(value) {
      const numeric = Number(value)
      return Number.isFinite(numeric) && numeric > 0 ? numeric : null
    },
    async ensureCurrentUser() {
      if (this.currentUser && this.currentUser.id) return this.currentUser
      if (!this.token) return null

      const res = await userApi.getInfo(this.token)
      const user = res && res.data ? res.data.userList : null
      if (user) {
        this.currentUser = user
      }
      return user
    },
    async fetchOtherProfile(userId) {
      const res = await userApi.getUserById(userId)
      if (!res || !res.data) {
        throw new Error('用户不存在')
      }
      return res.data
    },
    applyProfileToForm(profile) {
      this.editForm = {
        id: profile && profile.id ? profile.id : null,
        username: profile && profile.username ? profile.username : '',
        name: profile && profile.name ? profile.name : '',
        email: profile && profile.email ? profile.email : '',
        phone: profile && profile.phone ? profile.phone : '',
        bio: profile && profile.bio ? profile.bio : '',
        styleTags: profile && profile.styleTags ? profile.styleTags : '',
        avatar: profile && profile.avatar ? profile.avatar : '',
        coverImage: profile && profile.coverImage ? profile.coverImage : ''
      }
    },
    async fetchFollowStats() {
      if (!this.profileUserId) return
      try {
        const res = await followApi.count(this.profileUserId)
        this.followStats = res.data || { following: 0, followers: 0 }
      } catch (error) {
        this.followStats = { following: 0, followers: 0 }
      }
    },
    normalizeMediaItem(item) {
      return {
        ...item,
        photoUrl: normalizeImageUrl(item && item.photo),
        photoBroken: false
      }
    },
    normalizeMediaList(list) {
      return Array.isArray(list) ? list.map(item => this.normalizeMediaItem(item)) : []
    },
    openWorkPreview(item) {
      if (!item) return
      this.previewWorkItem = {
        ...item,
        photoUrl: normalizeImageUrl(item.photo) || item.photoUrl,
        photoBroken: !!item.photoBroken
      }
      this.workPreviewVisible = true
    },
    closeWorkPreview() {
      this.workPreviewVisible = false
      this.previewWorkItem = null
      this.previewDeleteLoading = false
    },
    async fetchWorks() {
      this.works.loading = true
      try {
        const res = await fenxiangApi.getList({
          userids: this.profileUserId,
          pageNo: this.works.pageNo,
          pageSize: this.works.pageSize
        })
        this.works.list = this.normalizeMediaList(res.data.rows || [])
        this.works.total = res.data.total || 0
        this.works.loaded = true
      } finally {
        this.works.loading = false
      }
    },
    async fetchShowcase() {
      this.showcase.loading = true
      try {
        const params = {
          shangjiaids: String(this.profileUserId),
          pageNo: this.showcase.pageNo,
          pageSize: this.showcase.pageSize
        }

        if (!this.isSelf) {
          params.type = '上架'
          params.status = '审核成功'
        }

        const res = await huagaoApi.getList(params)
        this.showcase.list = this.normalizeMediaList(res.data.rows || [])
        this.showcase.total = res.data.total || 0
        this.showcase.loaded = true
      } finally {
        this.showcase.loading = false
      }
    },
    async fetchProjects() {
      this.projects.loading = true
      try {
        const res = await projectApi.getList({
          userId: this.profileUserId,
          pageNo: this.projects.pageNo,
          pageSize: this.projects.pageSize
        })
        this.projects.list = res.data.rows || []
        this.projects.total = res.data.total || 0
        this.projects.loaded = true
      } finally {
        this.projects.loading = false
      }
    },
    async fetchFavorites() {
      if (!this.isSelf || !this.profileUserId) return
      this.favorites.loading = true
      try {
        const res = await shoucangApi.getList({
          userids: this.profileUserId,
          pageNo: this.favorites.pageNo,
          pageSize: this.favorites.pageSize
        })
        this.favorites.list = this.normalizeMediaList(res.data.rows || [])
        this.favorites.total = res.data.total || 0
        this.favorites.loaded = true
      } finally {
        this.favorites.loading = false
      }
    },
    async fetchCart() {
      if (!this.isSelf || !this.profileUserId) return
      this.cart.loading = true
      try {
        const res = await orderApi.getList({
          userids: String(this.profileUserId),
          status: '购物车',
          pageNo: this.cart.pageNo,
          pageSize: this.cart.pageSize
        })
        this.cart.list = this.normalizeMediaList(res.data.rows || [])
        this.cart.total = res.data.total || 0
        this.cart.loaded = true
      } finally {
        this.cart.loading = false
      }
    },
    async fetchOrders() {
      if (!this.isSelf) return
      this.orders.loading = true
      try {
        const res = await orderApi.getMine({
          role: this.orderViewRole,
          pageNo: this.orders.pageNo,
          pageSize: this.orders.pageSize
        })
        this.orders.list = res.data.rows || []
        this.orders.total = res.data.total || 0
        this.orders.loaded = true
      } finally {
        this.orders.loading = false
      }
    },
    ensureSectionData() {
      if (this.isSelf && this.activePrimaryTab === 'favorites' && !this.favorites.loaded && !this.favorites.loading) {
        this.fetchFavorites()
      }

      if (this.isSelf && this.activePrimaryTab === 'cart' && !this.cart.loaded && !this.cart.loading) {
        this.fetchCart()
      }

      if (this.isSelf && this.activePrimaryTab === 'orders' && !this.orders.loaded && !this.orders.loading) {
        this.fetchOrders()
      }
    },
    handlePrimaryTabChange() {
      const resolvedState = resolveCenterProfileState({
        isSelf: this.isSelf,
        viewMode: this.currentViewMode,
        tab: this.activePrimaryTab,
        sub: this.activeSecondaryTab
      })
      this.activePrimaryTab = resolvedState.tab
      this.activeSecondaryTab = resolvedState.sub
      this.ensureSectionData()
      this.replaceProfileRoute(resolvedState)
    },
    setPrimaryTab(tabKey) {
      if (tabKey === this.activePrimaryTab) return
      this.activePrimaryTab = tabKey
      this.handlePrimaryTabChange()
    },
    setSecondaryTab(tabKey) {
      if (tabKey === this.activeSecondaryTab) return
      this.activeSecondaryTab = tabKey
      this.ensureSectionData()
      this.replaceProfileRoute({
        viewMode: this.currentViewMode,
        tab: this.activePrimaryTab,
        sub: this.activeSecondaryTab
      })
    },
    handleCardImageError(item) {
      this.$set(item, 'photoBroken', true)
    },
    handlePreviewImageError() {
      if (this.previewWorkItem) {
        this.$set(this.previewWorkItem, 'photoBroken', true)
      }
    },
    goPreviewAuthor() {
      if (!this.profileUserId || this.isSelf) return
      this.workPreviewVisible = false
      this.$router.push(buildOtherArtistProfileRoute(this.profileUserId, 'featuredWorks'))
    },
    openEditDialog() {
      this.applyProfileToForm(this.profile)
      this.avatarUploading = false
      this.coverUploading = false
      this.editDialogVisible = true
    },
    onAvatarFileChange(file) {
      if (!file || !file.raw) return
      this.cropperMode = 'avatar'
      this.cropperImageUrl = URL.createObjectURL(file.raw)
      this.cropperVisible = true
    },
    onCoverFileChange(file) {
      if (!file || !file.raw) return
      this.cropperMode = 'cover'
      this.cropperImageUrl = URL.createObjectURL(file.raw)
      this.cropperVisible = true
    },
    onCropperClosed() {
      if (this.cropperImageUrl) {
        URL.revokeObjectURL(this.cropperImageUrl)
        this.cropperImageUrl = ''
      }
    },
    handleCropConfirm() {
      this.$refs.cropper.getCropBlob(blob => {
        if (!blob) {
          this.$message.error('裁剪失败')
          return
        }
        this.cropperUploading = true
        const formData = new FormData()
        formData.append('file', blob, `cropped_${Date.now()}.png`)
        const uploadUrl = ossUploadAction('photo')
        axios.post(uploadUrl, formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        }).then(res => {
          const response = res.data
          const field = this.cropperMode === 'avatar' ? 'avatar' : 'coverImage'
          const loadingKey = this.cropperMode === 'avatar' ? 'avatarUploading' : 'coverUploading'
          const successMsg = this.cropperMode === 'avatar' ? '头像裁剪上传成功，保存后生效' : '背景图裁剪上传成功，保存后生效'
          this.applyUploadedImage(field, response, loadingKey, successMsg)
          this.cropperVisible = false
        }).catch(() => {
          this.$message.error('上传失败')
        }).finally(() => {
          this.cropperUploading = false
        })
      })
    },
    beforeAvatarUpload() {
      this.avatarUploading = true
      return true
    },
    beforeCoverUpload() {
      this.coverUploading = true
      return true
    },
    handleProfileModeChange(nextMode) {
      const resolvedMode = normalizeProfileViewMode(nextMode, this.currentViewMode)
      if (resolvedMode === this.currentViewMode) return

      if (this.isSelf) {
        this.$store.commit('user/SET_DISPLAY_MODE', resolvedMode)
        this.orderViewRole = this.getDefaultOrderRole(resolvedMode)
      } else {
        this.otherDisplayMode = resolvedMode
      }

      const resolvedState = resolveCenterProfileState({
        isSelf: this.isSelf,
        viewMode: resolvedMode,
        tab: this.activePrimaryTab,
        sub: this.activeSecondaryTab
      })

      this.activePrimaryTab = resolvedState.tab
      this.activeSecondaryTab = resolvedState.sub
      this.ensureSectionData()
      this.replaceProfileRoute(resolvedState)

      const label = resolvedMode === 'artist' ? '画师' : '用户'
      this.$message.success(`已切换为${label}视图`)
    },
    buildProfilePayload(overrides = {}) {
      return {
        id: this.profile && this.profile.id ? this.profile.id : this.editForm.id,
        username: (this.profile && this.profile.username) || this.editForm.username || '',
        name: Object.prototype.hasOwnProperty.call(overrides, 'name') ? overrides.name : this.editForm.name,
        email: Object.prototype.hasOwnProperty.call(overrides, 'email') ? overrides.email : this.editForm.email,
        phone: Object.prototype.hasOwnProperty.call(overrides, 'phone') ? overrides.phone : this.editForm.phone,
        bio: Object.prototype.hasOwnProperty.call(overrides, 'bio') ? overrides.bio : this.editForm.bio,
        styleTags: Object.prototype.hasOwnProperty.call(overrides, 'styleTags') ? overrides.styleTags : this.editForm.styleTags,
        avatar: Object.prototype.hasOwnProperty.call(overrides, 'avatar') ? overrides.avatar : (this.editForm.avatar || (this.profile && this.profile.avatar) || ''),
        coverImage: Object.prototype.hasOwnProperty.call(overrides, 'coverImage') ? overrides.coverImage : (this.editForm.coverImage || (this.profile && this.profile.coverImage) || '')
      }
    },
    syncProfileState(profile) {
      if (!profile) return
      const nextProfile = { ...profile }
      this.profile = nextProfile
      if (this.isSelf) {
        this.currentUser = nextProfile
      }
      this.applyProfileToForm(nextProfile)
    },
    async refreshSelfProfile() {
      await this.$store.dispatch('user/getInfo')
      const res = await userApi.getInfo(this.token)
      const user = res && res.data ? res.data.userList : null
      if (user) {
        this.syncProfileState(user)
      }
    },
    async checkFollowStatus() {
      const followerId = this.userId || (this.currentUser && this.currentUser.id)
      if (!this.token || !followerId || !this.profileUserId || this.isSelf) {
        this.isFollowingProfile = false
        return
      }

      try {
        const res = await followApi.check({
          followerId,
          followingId: this.profileUserId
        })
        this.isFollowingProfile = !!(res && res.data)
      } catch (error) {
        this.isFollowingProfile = false
      }
    },
    async toggleFollowProfile() {
      const followerId = this.userId || (this.currentUser && this.currentUser.id)
      if (!this.token || !followerId) {
        this.$message.warning('请先登录')
        return
      }
      if (!this.profileUserId || this.isSelf) return

      this.followLoading = true
      try {
        if (this.isFollowingProfile) {
          await followApi.unfollow({
            followerId,
            followingId: this.profileUserId
          })
          this.isFollowingProfile = false
          this.$message.success('已取消关注')
        } else {
          await followApi.follow({
            followerId,
            followingId: this.profileUserId
          })
          this.isFollowingProfile = true
          this.$message.success('关注成功')
        }
        await this.fetchFollowStats()
      } catch (error) {
        this.$message.error('操作失败')
      } finally {
        this.followLoading = false
      }
    },
    async saveProfilePatch(overrides, successMessage) {
      this.saving = true
      try {
        await userApi.updateMyUser(this.buildProfilePayload(overrides))
        await this.refreshSelfProfile()
        this.$message.success(successMessage)
        return true
      } catch (error) {
        this.$message.error('保存失败')
        return false
      } finally {
        this.saving = false
      }
    },
    applyUploadedImage(field, response, loadingKey, successMessage) {
      const fileName = extractUploadFileName(response)
      if (!fileName) {
        this[loadingKey] = false
        this.$message.error((response && response.message) || '上传失败')
        return
      }

      const nextUrl = normalizeImageUrl(fileName)
      if (!nextUrl) {
        this[loadingKey] = false
        this.$message.error('上传返回的图片地址无效')
        return
      }

      this.editForm[field] = nextUrl
      this[loadingKey] = false
      this.$message.success(successMessage)
    },
    handleAvatarUploadSuccess(response) {
      this.applyUploadedImage('avatar', response, 'avatarUploading', '头像上传成功，保存后生效')
    },
    handleAvatarUploadError() {
      this.avatarUploading = false
      this.$message.error('头像上传失败')
    },
    handleCoverUploadSuccess(response) {
      this.applyUploadedImage('coverImage', response, 'coverUploading', '背景图上传成功，保存后生效')
    },
    handleCoverUploadError() {
      this.coverUploading = false
      this.$message.error('背景图上传失败')
    },
    async handleSaveProfile() {
      const success = await this.saveProfilePatch({}, '个人资料已更新')
      if (success) {
        this.editDialogVisible = false
      }
    },
    goFollows() {
      this.$router.push('/center/follows')
    },
    goPublishEntry(type) {
      if (type === 'projects') {
        this.$router.push('/publish/project')
        return
      }
      const query = type === 'showcase' ? { type: 'huagao' } : undefined
      this.$router.push({ path: '/publish/work', query })
    },
    goShowcaseDetail(id) {
      if (!id) return
      this.$router.push('/work/' + id)
    },
    goProjectDetail(id) {
      if (!id) return
      this.$router.push('/project/' + id)
    },
    async handleDeletePreviewWork() {
      if (!this.previewCanDelete || !this.previewWorkItem || !this.previewWorkItem.id) return
      this.$confirm(`确认删除作品《${this.previewWorkItem.title || '未命名作品'}》吗？删除后无法恢复。`, '删除确认', {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async() => {
        this.previewDeleteLoading = true
        try {
          const response = await fenxiangApi.deleteById(this.previewWorkItem.id)
          this.$message.success(response.message || '作品已删除')
          await this.fetchWorks()
          this.closeWorkPreview()
        } finally {
          this.previewDeleteLoading = false
        }
      }).catch(() => {})
    },
    openOrdersTab() {
      const wasOrdersTab = this.activePrimaryTab === 'orders'
      this.setPrimaryTab('orders')
      if (wasOrdersTab) {
        this.fetchOrders()
      }
    },
    async removeCartItem(item) {
      try {
        await orderApi.deleteById(item.id)
        this.$message.success('已从购物车移除')
        this.fetchCart()
      } catch (error) {
        this.$message.error('移除失败')
      }
    },
    formatBudget(item) {
      const min = item && item.budgetMin ? item.budgetMin : null
      const max = item && item.budgetMax ? item.budgetMax : null
      if (min !== null && max !== null) return `预算 ¥${min} - ¥${max}`
      if (min !== null) return `预算 ¥${min} 起`
      if (max !== null) return `预算最高 ¥${max}`
      return '预算待沟通'
    },
    statusTagType(status) {
      const tagMap = {
        '待支付': 'warning',
        '已支付': 'success',
        '已完成': 'success',
        '已取消': 'info',
        '退款中': 'danger'
      }
      return tagMap[status] || ''
    }
  }
}
</script>

<style lang="scss" scoped>
.profile-page {
  margin: 0;
  padding: 0 0 52px;
  background: #f5f5f5;
}

.page-loading {
  min-height: 360px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: #7b8796;
  font-size: 15px;
}

.profile-layout {
  width: 100%;
  background: #f5f5f5;
}

.profile-container {
  width: 100%;
  max-width: none;
  background: #f5f5f5;
}

.profile-banner {
  width: 100vw;
  margin-left: calc(50% - 50vw);
}

.profile-banner__surface {
  position: relative;
  width: 100%;
  height: 232px;
  overflow: hidden;
  border-radius: 0;
  background: linear-gradient(135deg, #d6def5 0%, #f2d4dc 50%, #d8e3fb 100%);
}

.profile-banner__cover-img,
.profile-banner__fallback,
.profile-banner__overlay {
  position: absolute;
  inset: 0;
}

.profile-banner__cover-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.profile-banner__fallback {
  display: flex;
  align-items: flex-end;
  justify-content: flex-start;
  padding: 18px 28px;
  background:
    radial-gradient(circle at top left, rgba(255, 255, 255, 0.32), transparent 28%),
    radial-gradient(circle at right center, rgba(120, 155, 255, 0.18), transparent 30%),
    linear-gradient(135deg, #d9dff1 0%, #f2dde1 48%, #d8e4fd 100%);
  color: rgba(255, 255, 255, 0.9);
  font-size: 13px;
}

.profile-banner__fallback span {
  padding: 7px 12px;
  border-radius: 999px;
  background: rgba(54, 66, 98, 0.16);
  backdrop-filter: blur(12px);
}

.profile-banner__overlay {
  background: linear-gradient(180deg, rgba(17, 24, 39, 0.05) 0%, rgba(17, 24, 39, 0.18) 100%);
  pointer-events: none;
}

.profile-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 32px;
  max-width: 1024px;
  margin-left: auto;
  margin-right: auto;
  padding: 0 24px 28px;
  margin-top: -36px;
  position: relative;
  z-index: 2;
}

.profile-left {
  display: flex;
  align-items: flex-start;
  gap: 28px;
  min-width: 0;
  flex: 1;
}

.profile-avatar {
  width: 108px;
  height: 108px;
  flex-shrink: 0;
  margin-top: 0;
  border-radius: 50%;
  border: 3px solid #fff;
  background: #fff;
  box-shadow: 0 10px 24px rgba(28, 39, 67, 0.1);
  overflow: hidden;
}

.profile-avatar__image {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.profile-avatar__fallback-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  font-size: 42px;
  color: #c0c4cc;
  background: #f5f7fa;
  border-radius: 50%;
}

.profile-meta {
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
  padding-top: 52px;
}

.profile-name {
  margin: 0;
  font-size: 32px;
  line-height: 1.08;
  font-weight: 700;
  letter-spacing: -0.02em;
  color: #131722;
}

.profile-handle-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px 16px;
  color: #778091;
  font-size: 14px;
}

.profile-handle,
.profile-location {
  display: inline-flex;
  align-items: center;
  gap: 5px;
}

.profile-inline-tag {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  background: #f3f5f8;
  color: #6b7383;
  font-size: 12px;
}

.profile-stats {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 28px;
  margin-top: 6px;
}

.profile-stat {
  border: 0;
  padding: 0;
  background: transparent;
  display: inline-flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 4px;
  min-width: 54px;
  text-align: left;
}

.profile-stat.is-link {
  cursor: pointer;
  transition: opacity 0.2s ease;
}

.profile-stat.is-link:hover {
  opacity: 0.74;
}

.profile-stat__value {
  font-size: 20px;
  line-height: 1;
  font-weight: 700;
  color: #171c27;
}

.profile-stat__label {
  font-size: 13px;
  color: #8791a3;
}

.profile-bio {
  max-width: 620px;
  margin: 4px 0 0;
  color: #4f5968;
  font-size: 15px;
  line-height: 1.9;
}

.profile-bio.is-empty {
  color: #98a2b3;
}

.profile-actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 12px;
  padding-top: 50px;
  flex-shrink: 0;
  min-width: 190px;
}

.profile-actions__primary {
  display: flex;
  justify-content: flex-end;
  width: 100%;
}

.profile-action-btn {
  min-width: 104px;
  height: 35px;
  padding: 0 17px;
  border-radius: 999px;
  border-color: #d9e0ea;
  background: #fff;
  color: #2f3947;
  font-size: 13px;
  font-weight: 500;
}

.profile-action-switch {
  display: inline-flex;
  align-items: center;
  justify-content: flex-end;
  gap: 8px;
  padding: 0;
  border: 0;
  border-radius: 999px;
  background: transparent;
}

.profile-action-switch__label {
  font-size: 11px;
  color: #96a1b1;
  white-space: nowrap;
}

.profile-action-switch ::v-deep .el-radio-group {
  display: inline-flex;
  gap: 2px;
  padding: 2px;
  border-radius: 999px;
  background: #f3f6fa;
}

.profile-action-switch ::v-deep .el-radio-button__inner {
  padding: 6px 12px;
  border: 0;
  border-radius: 999px;
  background: transparent;
  color: #738095;
  font-size: 12px;
  box-shadow: none;
}

.profile-action-switch ::v-deep .el-radio-button:first-child .el-radio-button__inner,
.profile-action-switch ::v-deep .el-radio-button:last-child .el-radio-button__inner {
  border-radius: 999px;
}

.profile-action-switch ::v-deep .el-radio-button__orig-radio:checked + .el-radio-button__inner {
  background: #0096fa;
  color: #fff;
}

.profile-tabs-wrap {
  margin-top: 18px;
  max-width: 1024px;
  margin-left: auto;
  margin-right: auto;
  padding: 0 24px;
}

.profile-tabs {
  display: flex;
  align-items: center;
  gap: 32px;
  border-bottom: 1px solid #e8ebf0;
  overflow-x: auto;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.profile-tabs::-webkit-scrollbar {
  display: none;
}

.profile-tabs__item {
  border: 0;
  padding: 0 0 14px;
  margin-bottom: -1px;
  background: transparent;
  color: #6b7280;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  outline: none;
  border-bottom: 3px solid transparent;
  transition: color 0.2s ease, border-color 0.2s ease;
  white-space: nowrap;
}

.profile-tabs__item:hover {
  color: #2b3340;
}

.profile-tabs__item.is-active {
  color: #0096fa;
  border-bottom-color: #0096fa;
}

.profile-subtabs {
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 14px 0 0;
}

.profile-subtabs__item {
  border: 0;
  padding: 0 0 8px;
  background: transparent;
  color: #848d9d;
  font-size: 14px;
  cursor: pointer;
  outline: none;
  border-bottom: 2px solid transparent;
  transition: color 0.2s ease, border-color 0.2s ease;
}

.profile-subtabs__item.is-active {
  color: #0096fa;
  border-bottom-color: #0096fa;
}

.profile-content {
  max-width: 1024px;
  margin: 0 auto;
  padding: 24px 24px 0;
}

.content-section {
  padding-top: 0;
}

.section-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 22px;
}

.section-heading__title {
  margin: 0;
  font-size: 23px;
  font-weight: 700;
  color: #202636;
}

.section-heading__desc {
  margin: 4px 0 0;
  color: #8b95a7;
  font-size: 14px;
}

.content-loading {
  padding: 48px 0;
  text-align: center;
  color: #97a3ad;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(212px, 1fr));
  gap: 14px;
}

.content-card {
  overflow: hidden;
  border: 1px solid #eef1f5;
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 6px 18px rgba(15, 23, 42, 0.04);
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.content-card.is-clickable {
  cursor: pointer;
}

.content-card:hover {
  transform: translateY(-2px);
  border-color: #dde4ee;
  box-shadow: 0 12px 22px rgba(15, 23, 42, 0.08);
}

.content-card__cover {
  position: relative;
  padding-top: 72%;
  overflow: hidden;
  background: #edf1f7;
}

.cover-img,
.cover-fallback {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

.cover-img {
  object-fit: cover;
}

.cover-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background:
    radial-gradient(circle at top left, rgba(173, 193, 255, 0.5), transparent 30%),
    linear-gradient(135deg, #eef2fa 0%, #f7f9fc 100%);
}

.cover-fallback__label {
  font-size: 12px;
  color: #7b8597;
}

.cover-price {
  position: absolute;
  right: 10px;
  bottom: 10px;
  padding: 4px 9px;
  border-radius: 999px;
  background: rgba(17, 24, 39, 0.72);
  color: #fff;
  font-size: 12px;
  font-weight: 600;
}

.content-card__body {
  padding: 12px 12px 13px;
}

.content-card__title {
  font-size: 14px;
  font-weight: 600;
  color: #202636;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.content-card__meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 7px;
}

.profile-preview-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.profile-preview-image {
  position: relative;
  width: 100%;
  max-height: 420px;
  overflow: hidden;
  border-radius: 12px;
  background: #f5f5f5;
}

.profile-preview-img {
  width: 100%;
  max-height: 420px;
  object-fit: contain;
}

.profile-preview-image__placeholder {
  min-height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #7b8796;
  background: linear-gradient(135deg, #eef2fa 0%, #f7f9fc 100%);
}

.profile-preview-image__actions {
  position: absolute;
  top: 14px;
  right: 14px;
}

.profile-preview-info {
  padding: 0 4px;
}

.profile-preview-author {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  cursor: pointer;
}

.profile-preview-author__avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
}

.profile-preview-author__name {
  font-size: 14px;
  font-weight: 500;
  color: #202636;
}

.profile-preview-title {
  margin: 0 0 10px;
  font-size: 18px;
  font-weight: 600;
  color: #202636;
}

.profile-preview-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 10px;
}

.profile-preview-desc {
  margin: 0;
  font-size: 14px;
  line-height: 1.75;
  color: #667085;
  white-space: pre-line;
}

.meta-tag {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  background: #f2f4f8;
  color: #667085;
  font-size: 12px;
}

.meta-note {
  font-size: 12px;
  color: #98a2b3;
}

.project-list,
.stack-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.project-card,
.stack-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding: 16px 18px;
  border: 1px solid #eef1f5;
  border-radius: 14px;
  background: #fff;
  box-shadow: 0 6px 18px rgba(15, 23, 42, 0.04);
}

.project-card.is-clickable {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.project-card.is-clickable:hover {
  transform: translateY(-2px);
  border-color: #dde4ee;
  box-shadow: 0 12px 22px rgba(15, 23, 42, 0.08);
}

.project-card__main,
.stack-card__main {
  flex: 1;
  min-width: 0;
}

.project-card__title,
.stack-card__title {
  font-size: 15px;
  font-weight: 600;
  color: #202636;
}

.project-card__desc {
  margin: 7px 0 0;
  color: #6b7280;
  font-size: 13px;
  line-height: 1.65;
}

.project-card__side {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8px;
  flex-shrink: 0;
}

.project-status {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  background: #eef6ff;
  color: #0096fa;
  font-size: 12px;
}

.project-budget {
  color: #8b95a7;
  font-size: 13px;
}

.stack-card__thumb {
  width: 82px;
  height: 82px;
  border-radius: 10px;
  object-fit: cover;
  flex-shrink: 0;
  background: #edf1f7;
}

.stack-card__thumb--empty {
  display: flex;
  align-items: center;
  justify-content: center;
}

.stack-card__thumb-label {
  font-size: 12px;
  color: #7b8597;
}

.stack-card__meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 7px;
}

.stack-card__actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 6px;
  flex-shrink: 0;
}

.price-text {
  color: #d96f32;
  font-weight: 600;
}

.orders-table {
  width: 100%;
}

.orders-table ::v-deep .el-table {
  border-radius: 16px;
  overflow: hidden;
}

.orders-table ::v-deep .el-table th {
  background: #f8f9fb;
  color: #667085;
}

.orders-table ::v-deep .el-table td,
.orders-table ::v-deep .el-table th.is-leaf {
  border-bottom-color: #edf0f5;
}

.edit-form {
  padding-top: 8px;
}

.edit-form__hint {
  margin-bottom: 18px;
  padding: 12px 14px;
  border-radius: 14px;
  background: #f7f9fc;
  color: #70808c;
  font-size: 13px;
  line-height: 1.6;
}

.edit-media-grid {
  display: grid;
  grid-template-columns: 220px minmax(0, 1fr);
  gap: 18px;
  margin-bottom: 22px;
}

.edit-media-card {
  border-radius: 18px;
  border: 1px solid #e7ecf3;
  background: #fbfcfe;
  padding: 16px;
}

.edit-media-card__header {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 12px;
}

.edit-media-card__title {
  font-size: 15px;
  font-weight: 600;
  color: #20313f;
}

.edit-media-card__desc {
  font-size: 12px;
  color: #7b8796;
}

.edit-avatar-preview {
  width: 132px;
  height: 132px;
  margin-bottom: 12px;
  border-radius: 28px;
  overflow: hidden;
  background: linear-gradient(135deg, #eff3f8 0%, #f7f9fc 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.edit-avatar-preview__img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.edit-avatar-preview__placeholder,
.edit-cover-preview__placeholder {
  font-size: 13px;
  color: #7b8796;
}

.edit-cover-preview {
  position: relative;
  min-height: 148px;
  margin-bottom: 12px;
  border-radius: 24px;
  overflow: hidden;
  background:
    radial-gradient(circle at top left, rgba(173, 193, 255, 0.45), transparent 30%),
    linear-gradient(135deg, #d9dff1 0%, #f2dde1 48%, #d8e4fd 100%);
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: center;
  justify-content: center;
}

.edit-cover-preview__mask {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(13, 22, 28, 0.08) 0%, rgba(13, 22, 28, 0.24) 100%);
}

.edit-cover-preview__placeholder {
  position: relative;
  z-index: 1;
  color: #f7f9ff;
}

.edit-upload ::v-deep .el-upload {
  display: inline-flex;
}

.cropper-container {
  width: 100%;
  height: 380px;
}

@media (max-width: 960px) {
  .profile-container {
    padding: 0 28px;
  }
}

@media (max-width: 768px) {
  .profile-banner__surface {
    height: 208px;
  }

  .profile-header {
    flex-direction: column;
    gap: 14px;
    margin-top: -32px;
  }

  .profile-left {
    flex-direction: column;
    gap: 14px;
  }

  .profile-avatar {
    width: 100px;
    height: 100px;
  }

  .profile-meta,
  .profile-actions {
    padding-top: 0;
  }

  .profile-meta {
    gap: 14px;
  }

  .profile-actions {
    width: 100%;
    align-items: flex-start;
    min-width: 0;
  }

  .profile-actions__primary {
    justify-content: flex-start;
  }

  .profile-stats {
    gap: 16px;
  }

  .edit-media-grid {
    grid-template-columns: 1fr;
  }

  .project-card,
  .stack-card {
    flex-direction: column;
    align-items: flex-start;
  }

  .project-card__side,
  .stack-card__actions {
    align-items: flex-start;
  }
}

@media (max-width: 520px) {
  .profile-container {
    padding: 0 16px;
  }

  .profile-name {
    font-size: 26px;
  }

  .profile-tabs,
  .profile-subtabs {
    gap: 16px;
  }

  .profile-banner__surface {
    height: 196px;
  }

  .profile-avatar {
    width: 92px;
    height: 92px;
  }

  .profile-stats {
    gap: 14px;
  }
}
</style>

<style lang="scss">
body.profile-page-view #app .main-container,
body.profile-page-view #app .app-main {
  background: #f5f5f5 !important;
}

body.profile-page-view #app .app-main {
  padding: 0 !important;
}

body.profile-page-view .main-layout {
  background: #f5f5f5 !important;
}

body.profile-page-view .main-layout__content {
  max-width: none !important;
  padding: 0 !important;
}

.profile-work-preview-dialog {
  border-radius: 16px;
  overflow: hidden;
}

.profile-work-preview-dialog .el-dialog__header {
  padding: 12px 16px 0;
}

.profile-work-preview-dialog .el-dialog__body {
  padding: 0 24px 24px;
}

.profile-preview-delete-btn {
  border-color: rgba(255, 255, 255, 0.92);
  background: rgba(255, 255, 255, 0.92);
  color: #202636;
  box-shadow: 0 8px 22px rgba(15, 23, 42, 0.12);
}

.profile-preview-delete-btn:hover,
.profile-preview-delete-btn:focus {
  border-color: #fff;
  background: #fff;
  color: #d14343;
}
</style>
